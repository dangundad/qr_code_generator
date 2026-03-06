import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:qr_code_generator/app/controllers/setting_controller.dart';
import 'package:qr_code_generator/app/pages/settings/settings_page.dart';
import 'package:qr_code_generator/app/translate/translate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Get.reset();
  });

  testWidgets('settings page exposes a rate app support action', (
    WidgetTester tester,
  ) async {
    var rateTapCount = 0;
    Get.put<SettingController>(
      SettingController(
        loadOnInit: false,
        rateAppFn: () async {
          rateTapCount++;
        },
        canLaunchUrlFn: (_) async => true,
        launchUrlFn: (uri, mode) async => true,
      ),
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        child: GetMaterialApp(
          translations: Languages(),
          locale: const Locale('en'),
          home: const SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Rate App'), findsOneWidget);

    await tester.tap(find.text('Rate App'));
    await tester.pumpAndSettle();

    expect(rateTapCount, 1);
  });
}
