// ================================================
// DangunDad Flutter App - app_routes.dart Template
// ================================================

// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const PREMIUM = _Paths.PREMIUM;
  static const SETTINGS = _Paths.SETTINGS;
  static const GUIDE = _Paths.GUIDE;
  static const HISTORY = _Paths.HISTORY;
  static const STATS = _Paths.STATS;
}

abstract class _Paths {
  static const HOME = '/home';
  static const PREMIUM = '/premium';
  static const SETTINGS = '/settings';
  static const GUIDE = '/guide';
  static const HISTORY = '/history';
  static const STATS = '/stats';
}





