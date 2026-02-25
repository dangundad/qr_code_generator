// ================================================
// DangunDad Flutter App - app_pages.dart Template
// ================================================
// qr_code_generator 燁살꼹????????
// mbti_pro ?袁⑥쨮?類ㅻ????쉘 疫꿸퀡而?(part ???쉘)
// ignore_for_file: constant_identifier_names
// import 'package:qr_code_generator/app/pages/settings/settings_page.dart';

import 'package:get/get.dart';
import 'package:qr_code_generator/app/bindings/app_binding.dart';
import 'package:qr_code_generator/app/pages/history/history_page.dart';
import 'package:qr_code_generator/app/pages/home/home_page.dart';
import 'package:qr_code_generator/app/pages/guide/guide_page.dart';
import 'package:qr_code_generator/app/pages/settings/settings_page.dart';
import 'package:qr_code_generator/app/pages/stats/stats_page.dart';
import 'package:qr_code_generator/app/pages/premium/premium_page.dart';
import 'package:qr_code_generator/app/pages/premium/premium_binding.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomePage(),
      binding: AppBinding(),
    ),
    // GetPage(
    //   name: _Paths.SETTINGS,
    //   page: () => const SettingsPage(),
    //   binding: BindingsBuilder(() {
    //     Get.lazyPut(() => SettingController());
    //   }),
    // ),
    // ---- ?源낇???륁뵠筌왖 ?곕떽? ----
    GetPage(name: _Paths.SETTINGS, page: () => const SettingsPage()),
    GetPage(name: _Paths.HISTORY, page: () => const HistoryPage()),
    GetPage(name: _Paths.STATS, page: () => const StatsPage()),
    GetPage(name: _Paths.GUIDE, page: () => const GuidePage()),
    GetPage(
      name: _Paths.PREMIUM,
      page: () => const PremiumPage(),
      binding: PremiumBinding(),
    ),
];
}

