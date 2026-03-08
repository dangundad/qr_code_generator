// ================================================
// DangunDad Flutter App - main.dart Template
// ================================================
// QrCodeGenerator, qr_code_generator 치환 후 사용
// mbti_pro 프로덕션 패턴 기반

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toastification/toastification.dart';

import 'package:qr_code_generator/app/admob/ads_helper.dart';
import 'package:qr_code_generator/app/admob/ads_interstitial.dart';
import 'package:qr_code_generator/app/admob/ads_rewarded.dart';
import 'package:qr_code_generator/app/bindings/app_binding.dart';
import 'package:qr_code_generator/app/routes/app_pages.dart';
import 'package:qr_code_generator/app/services/hive_service.dart';
import 'package:qr_code_generator/app/theme/app_flex_theme.dart';
import 'package:qr_code_generator/app/translate/translate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 릴리즈 모드에서 debugPrint 비활성화
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // 세로 모드 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // AdMob 초기화 (GDPR/CCPA 동의 → SDK 초기화)
  try {
    final canRequestAds = await AdHelper.initializeConsentAndAds();
    if (canRequestAds) {
      final status = await AdHelper.currentInitializationStatus();
      status?.adapterStatuses.forEach((key, value) {
        debugPrint('Adapter status for $key: ${value.description}');
      });
      debugPrint('AdMob initialized successfully');
    } else {
      debugPrint('AdMob initialization skipped until consent is available');
    }
  } catch (e) {
    debugPrint('AdMob initialization failed: $e');
  }

  await HiveService.init();
  Get.put<HiveService>(HiveService(), permanent: true);

  // Edge-to-Edge UI
  unawaited(
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    ),
  );

  // 광고 매니저 초기화
  Get.put(InterstitialAdManager(), permanent: true);
  Get.put(RewardedAdManager(), permanent: true);

  runApp(const QrCodeGeneratorApp());
}

class QrCodeGeneratorApp extends StatelessWidget {
  const QrCodeGeneratorApp({super.key});

  Widget _buildFallbackApp() {
    return ToastificationWrapper(
      child: GetMaterialApp(
        supportedLocales: Languages.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        translations: Languages(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: AppFlexTheme.light,
        darkTheme: AppFlexTheme.dark,
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        if (!Get.isRegistered<HiveService>()) {
          return _buildFallbackApp();
        }

        return ToastificationWrapper(
          child: GetMaterialApp(
            supportedLocales: Languages.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            translations: Languages(),
            locale: Get.deviceLocale ?? const Locale('en'),
            fallbackLocale: const Locale('en'),
            debugShowCheckedModeBanner: false,
            defaultTransition: Transition.fadeIn,
            initialBinding: AppBinding(),
            themeMode: ThemeMode.system,
            theme: AppFlexTheme.light,
            darkTheme: AppFlexTheme.dark,
            scrollBehavior: ScrollBehavior().copyWith(overscroll: false),
            navigatorKey: Get.key,
            getPages: AppPages.routes,
            initialRoute: AppPages.INITIAL,
          ),
        );
      },
    );
  }
}
