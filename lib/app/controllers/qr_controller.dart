import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import 'package:qr_code_generator/app/data/enums/qr_type.dart';
import 'package:qr_code_generator/app/services/hive_service.dart';

class QrController extends GetxController {
  static QrController get to => Get.find();

  static const _historyKey = 'qr_history_json';
  static const _maxHistory = 20;

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

  @override
  void onInit() {
    super.onInit();
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

    ever(qrType, (_) => _updateQrData());
    ever(wifiSecurity, (_) => _updateQrData());
    ever(wifiHidden, (_) => _updateQrData());
  }

  @override
  void onClose() {
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
      HapticFeedback.lightImpact();
    }
    qrData.value = newData;
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
        return 'WIFI:T:$sec;S:$ssid;P:$pass;$hidden;';

      case QrType.contact:
        final name = contactNameCtrl.text.trim();
        if (name.isEmpty) return '';
        final phone = contactPhoneCtrl.text.trim();
        final email = contactEmailCtrl.text.trim();
        final org = contactOrgCtrl.text.trim();
        final buf = StringBuffer();
        buf.write('BEGIN:VCARD\nVERSION:3.0\n');
        buf.write('FN:$name\n');
        if (phone.isNotEmpty) buf.write('TEL:$phone\n');
        if (email.isNotEmpty) buf.write('EMAIL:$email\n');
        if (org.isNotEmpty) buf.write('ORG:$org\n');
        buf.write('END:VCARD');
        return buf.toString();

      case QrType.email:
        final addr = emailAddressCtrl.text.trim();
        if (addr.isEmpty) return '';
        final sub = Uri.encodeComponent(emailSubjectCtrl.text.trim());
        final body = Uri.encodeComponent(emailBodyCtrl.text.trim());
        return 'mailto:$addr?subject=$sub&body=$body';
    }
  }

  // ─── Share / Save ──────────────────────────────

  Future<void> shareQr() async {
    if (qrData.value.isEmpty) {
      Get.snackbar('error'.tr, 'qr_empty_error'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      final boundary =
          qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      HapticFeedback.lightImpact();
      await _shareImageBytes(bytes);
      _addToHistory();
    } catch (e) {
      Get.snackbar('error'.tr, '$e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _shareImageBytes(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/qrcode_${DateTime.now().millisecondsSinceEpoch}.png');
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
      Get.snackbar('error'.tr, 'qr_empty_error'.tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      final boundary = qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      HapticFeedback.lightImpact();
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          Get.snackbar('error'.tr, 'gallery_permission_denied'.tr, snackPosition: SnackPosition.BOTTOM);
          return;
        }
      }
      await Gal.putImageBytes(bytes, album: 'QR Generator');
      _addToHistory();
      Get.snackbar('success'.tr, 'saved_to_gallery'.tr, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('error'.tr, '$e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void copyContent() {
    if (qrData.value.isEmpty) return;
    HapticFeedback.lightImpact();
    Get.snackbar('copied'.tr, qrData.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
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
    if (history.length > _maxHistory) history.removeLast();
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
        return 'history_wifi_label'.trParams({'ssid': wifiSsidCtrl.text.trim()});
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
}
