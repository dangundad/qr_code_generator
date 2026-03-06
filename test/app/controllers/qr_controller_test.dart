import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qr_code_generator/app/controllers/qr_controller.dart';
import 'package:qr_code_generator/app/utils/app_toast.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
}
