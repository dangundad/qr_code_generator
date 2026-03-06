# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

QR 코드 생성기 앱. URL, 텍스트, Wi-Fi, 연락처(vCard), 이메일 등 다양한 유형의 QR 코드를 생성하고 색상 커스터마이징, 갤러리 저장, 공유 기능을 제공합니다.

- 패키지명: `com.dangundad.qrcodegenerator`
- 개발사: DangunDad (`dangundad@gmail.com`)
- 설계 크기: 375x812 (ScreenUtil 기준)
- 테마: `FlexScheme.blueM3` (라이트/다크 모두)

## 기술 스택

| 영역 | 기술 |
|------|------|
| 상태 관리 | GetX (`GetxController`, `.obs`, `Obx()`) |
| 로컬 저장 | Hive_CE (설정/앱 데이터 박스) |
| UI 반응형 | flutter_screenutil |
| 테마 | flex_color_scheme (`FlexScheme.blueM3`) |
| QR 생성 | qr_flutter |
| 갤러리 저장 | gal |
| 광고 | google_mobile_ads + AdMob 미디에이션 (AppLovin, Pangle, Unity) |
| 인앱 구매 | in_app_purchase |
| 다국어 | GetX 번역 (ko) |

## 개발 명령어

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

## 아키텍처

### 프로젝트 구조

```
lib/
├── main.dart
├── hive_registrar.g.dart
├── app/
│   ├── admob/
│   │   ├── ads_banner.dart
│   │   ├── ads_helper.dart
│   │   ├── ads_interstitial.dart
│   │   └── ads_rewarded.dart
│   ├── bindings/
│   │   └── app_binding.dart
│   ├── controllers/
│   │   ├── history_controller.dart
│   │   ├── home_controller.dart
│   │   ├── premium_controller.dart
│   │   ├── qr_controller.dart
│   │   ├── setting_controller.dart
│   │   └── stats_controller.dart
│   ├── data/
│   │   └── enums/
│   │       └── qr_type.dart          # url, text, wifi, contact, email
│   ├── pages/
│   │   ├── guide/guide_page.dart
│   │   ├── history/history_page.dart
│   │   ├── home/home_page.dart
│   │   ├── premium/
│   │   │   ├── premium_binding.dart
│   │   │   └── premium_page.dart
│   │   ├── settings/settings_page.dart
│   │   └── stats/stats_page.dart
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   ├── services/
│   │   ├── activity_log_service.dart
│   │   ├── app_rating_service.dart
│   │   ├── hive_service.dart
│   │   └── purchase_service.dart
│   ├── theme/
│   │   └── app_flex_theme.dart
│   ├── translate/
│   │   └── translate.dart
│   └── utils/
│       └── app_constants.dart
```

### 서비스 초기화 흐름

`main()` -> AdMob 동의 폼 초기화 -> `AppBinding.initializeServices()` (Hive 초기화 + 서비스 등록) -> `runApp()`

### GetX 의존성 트리

**영구 서비스 (permanent: true)**
- `HiveService` -- Hive 박스 관리 (`settings`, `app_data`)
- `ActivityLogService` -- 이벤트 로그
- `PurchaseService` -- IAP 관리, 프리미엄 상태에 따라 광고 매니저 동적 등록/해제
- `QrController` -- QR 생성 핵심 로직 (유형별 입력, 히스토리, 공유/저장)
- `SettingController` -- 앱 설정
- `InterstitialAdManager` / `RewardedAdManager` -- 광고 (비프리미엄 시)

**LazyPut (필요 시 생성)**
- `HistoryController`, `StatsController`, `PremiumController`

### 라우팅

| 경로 | 페이지 | 바인딩 |
|------|--------|--------|
| `/home` | `HomePage` | `AppBinding` |
| `/guide` | `GuidePage` | -- |
| `/settings` | `SettingsPage` | -- |
| `/history` | `HistoryPage` | -- |
| `/stats` | `StatsPage` | -- |
| `/premium` | `PremiumPage` | `PremiumBinding` |

### QR 생성 핵심 구조

`QrController`가 5가지 QR 유형(`QrType`: url, text, wifi, contact, email)을 관리합니다.
- 각 유형별 `TextEditingController`로 입력 수집
- `_buildQrString()`에서 유형별 포맷 변환 (vCard 3.0, Wi-Fi QR 스펙, mailto: 등)
- Wi-Fi 필드 특수문자 이스케이프 처리 (`_escapeWifiField`)
- QR 외관: 전경색 6종 + 배경색 6종 선택 가능
- `RepaintBoundary` + `toImage()`로 QR 이미지 캡처 후 공유/저장

### 히스토리 시스템

- JSON 직렬화로 Hive `app_data` 박스에 저장
- 기본 20개 제한, 보상형 광고 시청 시 999개로 확장
- 중복 콘텐츠 자동 제거 (최신이 앞으로)

### 스토리지 구조

| Hive 박스 | 용도 | 담당 서비스 |
|-----------|------|-------------|
| `settings` | 범용 설정 (key-value) | `HiveService` |
| `app_data` | 범용 앱 데이터 (히스토리 JSON 등) | `HiveService` |

### 다국어

현재 `ko` 키만 정의. 새 문자열은 `lib/app/translate/translate.dart`에 `ko` 섹션에만 추가.

## 개발 가이드라인

- QR 유형 추가 시: `QrType` enum 확장 + `_buildQrString()` case 추가 + 입력 폼 UI 추가
- 색상 옵션 추가 시: `QrController.fgColorOptions` / `bgColorOptions` 수정
- Worker (`ever`)는 `onClose()`에서 반드시 dispose
- TextEditingController도 `onClose()`에서 dispose 필수
