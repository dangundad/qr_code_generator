import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import 'package:qr_code_generator/app/admob/ads_rewarded.dart';
import 'package:qr_code_generator/app/controllers/setting_controller.dart';
import 'package:qr_code_generator/app/data/enums/qr_type.dart';
import 'package:qr_code_generator/app/services/hive_service.dart';
import 'package:qr_code_generator/app/utils/app_toast.dart';

typedef ClipboardSetter = Future<void> Function(ClipboardData data);
typedef QrImageBytesProvider = Future<Uint8List?> Function();
typedef GalleryImageSaver =
    Future<void> Function(Uint8List bytes, {String? album, String? name});

class QrController extends GetxController {
  QrController({
    ClipboardSetter? clipboardSetter,
    AppToastPresenter? toastPresenter,
    QrImageBytesProvider? qrImageBytesProvider,
    GalleryImageSaver? galleryImageSaver,
  }) : _clipboardSetter = clipboardSetter ?? Clipboard.setData,
       _toastPresenter = toastPresenter ?? AppToast.show,
       _qrImageBytesProvider = qrImageBytesProvider,
       _galleryImageSaver = galleryImageSaver;

  static QrController get to => Get.find();

  static const _historyKey = 'qr_history_json';
  static const _historyUnlockedKey = 'qr_history_unlocked';
  static const _defaultMaxHistory = 20;
  static const _unlockedMaxHistory = 999;

  final ClipboardSetter _clipboardSetter;
  final AppToastPresenter _toastPresenter;
  final QrImageBytesProvider? _qrImageBytesProvider;
  final GalleryImageSaver? _galleryImageSaver;

  // Observable max history limit
  final maxHistory = _defaultMaxHistory.obs;

  // Type
  final qrType = QrType.url.obs;

  // URL
  final urlCtrl = TextEditingController();

  // Text
  final textCtrl = TextEditingController();

  // WiFi
  final wifiSsidCtrl = TextEditingController();
  final wifiPasswordCtrl = TextEditingController();
  final wifiSecurity = 'WPA'.obs; // WPA, WEP, nopass
  final wifiHidden = false.obs;

  // Contact
  final contactNameCtrl = TextEditingController();
  final contactPhoneCtrl = TextEditingController();
  final contactEmailCtrl = TextEditingController();
  final contactOrgCtrl = TextEditingController();

  // Email
  final emailAddressCtrl = TextEditingController();
  final emailSubjectCtrl = TextEditingController();
  final emailBodyCtrl = TextEditingController();

  // Appearance
  static const List<int> fgColorOptions = [
    0xFF000000,
    0xFF1565C0,
    0xFF1B5E20,
    0xFF4A148C,
    0xFFB71C1C,
    0xFF212121,
  ];
  static const List<int> bgColorOptions = [
    0xFFFFFFFF,
    0xFFFFF9C4,
    0xFFE8F5E9,
    0xFFE3F2FD,
    0xFFF3E5F5,
    0xFFFFEBEE,
  ];

  final fgColor = 0xFF000000.obs;
  final bgColor = 0xFFFFFFFF.obs;

  // Generated QR data
  final qrData = ''.obs;

  // History
  final history = <Map<String, String>>[].obs;

  // RepaintBoundary key for screenshot
  final qrKey = GlobalKey();

  bool _hasVibrator = false;

  // Workers
  late final Worker _workerQrType;
  late final Worker _workerWifiSecurity;
  late final Worker _workerWifiHidden;

  @override
  void onInit() {
    super.onInit();
    Vibration.hasVibrator().then((v) => _hasVibrator = v);
    _loadHistoryLimit();
    _loadHistory();

    // Listeners to regenerate QR data
    urlCtrl.addListener(_updateQrData);
    textCtrl.addListener(_updateQrData);
    wifiSsidCtrl.addListener(_updateQrData);
    wifiPasswordCtrl.addListener(_updateQrData);
    contactNameCtrl.addListener(_updateQrData);
    contactPhoneCtrl.addListener(_updateQrData);
    contactEmailCtrl.addListener(_updateQrData);
    contactOrgCtrl.addListener(_updateQrData);
    emailAddressCtrl.addListener(_updateQrData);
    emailSubjectCtrl.addListener(_updateQrData);
    emailBodyCtrl.addListener(_updateQrData);

    _workerQrType = ever(qrType, (_) => _updateQrData());
    _workerWifiSecurity = ever(wifiSecurity, (_) => _updateQrData());
    _workerWifiHidden = ever(wifiHidden, (_) => _updateQrData());
  }

  @override
  void onClose() {
    _workerQrType.dispose();
    _workerWifiSecurity.dispose();
    _workerWifiHidden.dispose();
    urlCtrl.dispose();
    textCtrl.dispose();
    wifiSsidCtrl.dispose();
    wifiPasswordCtrl.dispose();
    contactNameCtrl.dispose();
    contactPhoneCtrl.dispose();
    contactEmailCtrl.dispose();
    contactOrgCtrl.dispose();
    emailAddressCtrl.dispose();
    emailSubjectCtrl.dispose();
    emailBodyCtrl.dispose();
    super.onClose();
  }

  void _updateQrData() {
    final newData = _buildQrString();
    if (newData.isNotEmpty && qrData.value != newData) {
      _haptic();
    }
    qrData.value = newData;
  }

  void _haptic() {
    if (Get.isRegistered<SettingController>() &&
        !SettingController.to.hapticEnabled.value) {
      return;
    }
    if (_hasVibrator) Vibration.vibrate(duration: 50);
  }

  String _buildQrString() {
    switch (qrType.value) {
      case QrType.url:
        final url = urlCtrl.text.trim();
        if (url.isEmpty) return '';
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          return 'https://$url';
        }
        return url;

      case QrType.text:
        return textCtrl.text.trim();

      case QrType.wifi:
        final ssid = wifiSsidCtrl.text.trim();
        if (ssid.isEmpty) return '';
        final pass = wifiPasswordCtrl.text;
        final sec = wifiSecurity.value;
        final hidden = wifiHidden.value ? 'H:true;' : '';
        final escapedSsid = _escapeWifiField(ssid);
        final escapedPass = _escapeWifiField(pass);
        if (sec == 'nopass') {
          return 'WIFI:T:nopass;S:$escapedSsid;P:;$hidden;';
        }
        return 'WIFI:T:$sec;S:$escapedSsid;P:$escapedPass;$hidden;';

      case QrType.contact:
        final name = contactNameCtrl.text.trim();
        if (name.isEmpty) return '';
        final phone = contactPhoneCtrl.text.trim();
        final email = contactEmailCtrl.text.trim();
        final org = contactOrgCtrl.text.trim();
        final buf = StringBuffer();
        buf.write('BEGIN:VCARD\r\nVERSION:3.0\r\n');
        // N field required by vCard 3.0: Family;Given;Additional;Prefix;Suffix
        final nameParts = name.split(' ');
        final given = nameParts.first;
        final family = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : '';
        buf.write('N:$family;$given;;;\r\n');
        buf.write('FN:$name\r\n');
        if (phone.isNotEmpty) buf.write('TEL;TYPE=CELL:$phone\r\n');
        if (email.isNotEmpty) buf.write('EMAIL;TYPE=INTERNET:$email\r\n');
        if (org.isNotEmpty) buf.write('ORG:$org\r\n');
        buf.write('END:VCARD');
        return buf.toString();

      case QrType.email:
        final addr = emailAddressCtrl.text.trim();
        if (addr.isEmpty) return '';
        final sub = emailSubjectCtrl.text.trim();
        final body = emailBodyCtrl.text.trim();
        final params = <String>[];
        if (sub.isNotEmpty) params.add('subject=${Uri.encodeComponent(sub)}');
        if (body.isNotEmpty) params.add('body=${Uri.encodeComponent(body)}');
        if (params.isEmpty) return 'mailto:$addr';
        return 'mailto:$addr?${params.join('&')}';
    }
  }

  /// Escapes special characters in Wi-Fi QR fields per the spec:
  /// backslash, semicolon, comma, double-quote must be escaped with \
  String _escapeWifiField(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll(';', r'\;')
        .replaceAll(',', r'\,')
        .replaceAll('"', r'\"');
  }

  // ─── Share / Save ──────────────────────────────

  Future<void> shareQr() async {
    if (qrData.value.isEmpty) {
      _showErrorToast('qr_empty_error'.tr);
      return;
    }
    try {
      final bytes = await _resolveQrImageBytes();
      if (bytes == null) return;
      _haptic();
      await _shareImageBytes(bytes);
      _addToHistory();
    } catch (e) {
      _showErrorToast('$e');
    }
  }

  Future<void> _shareImageBytes(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/qrcode_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: qrData.value,
      ),
    );
  }

  Future<void> saveToGallery() async {
    if (qrData.value.isEmpty) {
      _showErrorToast('qr_empty_error'.tr);
      return;
    }
    try {
      final bytes = await _resolveQrImageBytes();
      if (bytes == null) return;
      final fileName = _buildGalleryFileName();
      _haptic();
      if (_galleryImageSaver == null) {
        final hasAccess = await Gal.hasAccess(toAlbum: true);
        if (!hasAccess) {
          final granted = await Gal.requestAccess(toAlbum: true);
          if (!granted) {
            _showErrorToast('gallery_permission_denied'.tr);
            return;
          }
        }
      }
      await _saveImageToGallery(bytes, album: 'QR Generator', name: fileName);
      _addToHistory();
      _toastPresenter(
        AppToastMessage.success(
          title: 'success'.tr,
          description: 'saved_to_gallery'.tr,
        ),
      );
    } on GalException catch (e) {
      if (e.type == GalExceptionType.accessDenied) {
        _showErrorToast('gallery_permission_denied'.tr);
        return;
      }
      _showErrorToast('$e');
    } catch (e) {
      _showErrorToast('$e');
    }
  }

  Future<void> copyContent() async {
    if (qrData.value.isEmpty) return;
    _haptic();
    try {
      await _clipboardSetter(ClipboardData(text: qrData.value));
      _toastPresenter(
        AppToastMessage.success(title: 'copied'.tr, description: qrData.value),
      );
    } catch (e) {
      _showErrorToast('$e');
    }
  }

  void clearForm() {
    switch (qrType.value) {
      case QrType.url:
        urlCtrl.clear();
      case QrType.text:
        textCtrl.clear();
      case QrType.wifi:
        wifiSsidCtrl.clear();
        wifiPasswordCtrl.clear();
        wifiSecurity.value = 'WPA';
        wifiHidden.value = false;
      case QrType.contact:
        contactNameCtrl.clear();
        contactPhoneCtrl.clear();
        contactEmailCtrl.clear();
        contactOrgCtrl.clear();
      case QrType.email:
        emailAddressCtrl.clear();
        emailSubjectCtrl.clear();
        emailBodyCtrl.clear();
    }
  }

  // ─── History limit unlock ───────────────────────

  void _loadHistoryLimit() {
    final unlocked =
        HiveService.to.getAppData<bool>(_historyUnlockedKey) ?? false;
    maxHistory.value = unlocked ? _unlockedMaxHistory : _defaultMaxHistory;
  }

  bool get isHistoryUnlimited => maxHistory.value >= _unlockedMaxHistory;

  void unlockUnlimitedHistory() {
    RewardedAdManager.to.showAdIfAvailable(
      onUserEarnedReward: (_) async {
        maxHistory.value = _unlockedMaxHistory;
        await HiveService.to.setAppData(_historyUnlockedKey, true);
        _toastPresenter(
          AppToastMessage.success(
            title: 'history_unlocked_title'.tr,
            description: 'history_unlocked_desc'.tr,
          ),
        );
      },
    );
  }

  // ─── History ────────────────────────────────────

  void _loadHistory() {
    final raw = HiveService.to.getAppData<String>(_historyKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List;
      history.assignAll(
        list.map((e) => Map<String, String>.from(e as Map)).toList(),
      );
    } catch (_) {}
  }

  void _addToHistory() {
    final data = qrData.value;
    if (data.isEmpty) return;
    final entry = {
      'type': qrType.value.name,
      'content': data,
      'label': _buildLabel(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    // Remove duplicate
    history.removeWhere((e) => e['content'] == data);
    history.insert(0, entry);
    if (history.length > maxHistory.value) history.removeLast();
    _saveHistory();
  }

  String _buildLabel() {
    switch (qrType.value) {
      case QrType.url:
        return urlCtrl.text.trim();
      case QrType.text:
        final t = textCtrl.text.trim();
        return t.length > 30 ? '${t.substring(0, 30)}…' : t;
      case QrType.wifi:
        return 'history_wifi_label'.trParams({
          'ssid': wifiSsidCtrl.text.trim(),
        });
      case QrType.contact:
        return contactNameCtrl.text.trim();
      case QrType.email:
        return emailAddressCtrl.text.trim();
    }
  }

  Future<void> _saveHistory() async {
    await HiveService.to.setAppData(_historyKey, jsonEncode(history));
  }

  void loadFromHistory(Map<String, String> entry) {
    final type = QrType.values.firstWhere(
      (t) => t.name == entry['type'],
      orElse: () => QrType.url,
    );
    qrType.value = type;
    // Just set the qrData directly for preview (read-only mode in history)
    qrData.value = entry['content'] ?? '';
  }

  void deleteHistory(int index) {
    history.removeAt(index);
    _saveHistory();
  }

  void clearHistory() {
    history.clear();
    _saveHistory();
  }

  void _showErrorToast(String description) {
    _toastPresenter(
      AppToastMessage.error(title: 'error'.tr, description: description),
    );
  }

  Future<Uint8List?> _resolveQrImageBytes() async {
    final injectedProvider = _qrImageBytesProvider;
    if (injectedProvider != null) {
      return injectedProvider();
    }

    final boundary =
        qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _saveImageToGallery(
    Uint8List bytes, {
    required String album,
    required String name,
  }) async {
    final injectedSaver = _galleryImageSaver;
    if (injectedSaver != null) {
      await injectedSaver(bytes, album: album, name: name);
      return;
    }

    await Gal.putImageBytes(bytes, album: album, name: name);
  }

  String _buildGalleryFileName() {
    return 'qrcode_${DateTime.now().millisecondsSinceEpoch}.png';
  }
}
