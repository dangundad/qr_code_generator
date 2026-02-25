// ================================================
// DangunDad Flutter App - app_routes.dart Template
// ================================================
// mbti_pro ?袁⑥쨮?類ㅻ????쉘 疫꿸퀡而?(part of ???쉘)

// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const PREMIUM = _Paths.PREMIUM;
  static const SETTINGS = _Paths.SETTINGS;
  static const GUIDE = _Paths.GUIDE;
  // ---- ?源낇???깆뒭???곕떽? ----
  static const HISTORY = _Paths.HISTORY;
  static const STATS = _Paths.STATS;
}

abstract class _Paths {
  static const HOME = '/home';
  static const PREMIUM = '/premium';
  static const SETTINGS = '/settings';
  static const GUIDE = '/guide';
  // ---- ?源낇?野껋럥以??곕떽? ----
  static const HISTORY = '/history';
  static const STATS = '/stats';
}





