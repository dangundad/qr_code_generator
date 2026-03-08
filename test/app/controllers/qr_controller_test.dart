import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';

import 'package:qr_code_generator/app/controllers/qr_controller.dart';
import 'package:qr_code_generator/app/services/hive_service.dart';
import 'package:qr_code_generator/app/utils/app_toast.dart';

class _FakeHiveService extends HiveService {
  final Map<String, dynamic> _appData = {};

  @override
  T? getAppData<T>(String key, {T? defaultValue}) {
    return (_appData[key] as T?) ?? defaultValue;
  }

  @override
  Future<void> setAppData(String key, dynamic value) async {
    _appData[key] = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.put<HiveService>(_FakeHiveService());
  });

  tearDown(Get.reset);

  test('copyContent copies QR data and emits a success toast', () async {
    ClipboardData? copiedData;
    final messages = <AppToastMessage>[];
    final controller = QrController(
      clipboardSetter: (data) async {
        copiedData = data;
      },
      toastPresenter: messages.add,
    );

    controller.qrData.value = 'https://example.com';
    await controller.copyContent();

    expect(copiedData?.text, 'https://example.com');
    expect(messages, hasLength(1));
    expect(messages.single.type, AppToastType.success);
    expect(messages.single.description, 'https://example.com');
  });

  test('shareQr emits an error toast when there is no QR data', () async {
    final messages = <AppToastMessage>[];
    final controller = QrController(toastPresenter: messages.add);

    await controller.shareQr();

    expect(messages, hasLength(1));
    expect(messages.single.type, AppToastType.error);
  });

  test('saveToGallery saves QR bytes with album and file name', () async {
    final messages = <AppToastMessage>[];
    Uint8List? savedBytes;
    String? savedAlbum;
    String? savedName;
    final controller = QrController(
      toastPresenter: messages.add,
      qrImageBytesProvider: () async => Uint8List.fromList([1, 2, 3]),
      galleryImageSaver: (bytes, {album, name}) async {
        savedBytes = bytes;
        savedAlbum = album;
        savedName = name;
      },
    );

    controller.qrData.value = 'https://example.com';
    await controller.saveToGallery();

    expect(savedBytes, Uint8List.fromList([1, 2, 3]));
    expect(savedAlbum, 'QR Generator');
    expect(savedName, startsWith('qrcode_'));
    expect(savedName, endsWith('.png'));
    expect(messages, hasLength(1));
    expect(messages.single.type, AppToastType.success);
    expect(messages.single.description, 'saved_to_gallery');
  });

  test('saveToGallery maps gallery access denial to permission toast', () async {
    final messages = <AppToastMessage>[];
    final controller = QrController(
      toastPresenter: messages.add,
      qrImageBytesProvider: () async => Uint8List.fromList([1, 2, 3]),
      galleryImageSaver: (_, {album, name}) async {
        throw GalException(
          type: GalExceptionType.accessDenied,
          platformException: PlatformException(code: 'ACCESS_DENIED'),
          stackTrace: StackTrace.current,
        );
      },
    );

    controller.qrData.value = 'https://example.com';
    await controller.saveToGallery();

    expect(messages, hasLength(1));
    expect(messages.single.type, AppToastType.error);
    expect(messages.single.description, 'gallery_permission_denied');
  });
}
