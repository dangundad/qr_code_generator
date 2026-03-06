# QR Code Generator

URL, 텍스트, Wi-Fi, 연락처, 이메일 등 다양한 유형의 QR 코드를 생성하고 커스터마이징할 수 있는 Flutter 앱입니다.

## 주요 기능

- **5가지 QR 유형**: URL, 텍스트, Wi-Fi, 연락처(vCard 3.0), 이메일(mailto)
- **색상 커스터마이징**: 전경색 6종 + 배경색 6종 조합
- **갤러리 저장**: 생성된 QR 코드를 이미지로 기기 갤러리에 저장
- **공유**: QR 코드 이미지를 다른 앱으로 공유
- **클립보드 복사**: QR 데이터 텍스트 복사
- **히스토리**: 생성 이력 관리 (기본 20개, 보상형 광고 시청 시 999개 확장)
- **프리미엄**: 인앱 구매로 광고 제거

## 기술 스택

- **Flutter** (Dart)
- **GetX** - 상태 관리, 라우팅, 다국어
- **Hive_CE** - 로컬 데이터 저장
- **qr_flutter** - QR 코드 렌더링
- **gal** - 갤러리 저장
- **flex_color_scheme** - 테마 (`FlexScheme.blueM3`)
- **flutter_screenutil** - 반응형 UI
- **google_mobile_ads** - AdMob 광고 (배너 + 전면 + 보상형)

## 설치 및 실행

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

## 프로젝트 구조

```
lib/
├── main.dart
├── app/
│   ├── admob/              # AdMob 광고 관리
│   ├── bindings/           # GetX 바인딩
│   ├── controllers/        # QrController, SettingController 등
│   ├── data/enums/         # QrType (url, text, wifi, contact, email)
│   ├── pages/              # 화면별 UI
│   ├── routes/             # GetX 라우팅
│   ├── services/           # HiveService, PurchaseService 등
│   ├── theme/              # FlexColorScheme 테마
│   ├── translate/          # 다국어 (ko)
│   └── utils/              # 상수 정의
```

## 라이선스

Copyright 2026 DangunDad. All rights reserved.
