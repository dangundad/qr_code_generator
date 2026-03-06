# QR Code Generator - TODO

## 구현 완료 기능

- [x] 5가지 QR 유형 생성 (URL, 텍스트, Wi-Fi, 연락처 vCard 3.0, 이메일 mailto)
- [x] QR 색상 커스터마이징 (전경색 6종 + 배경색 6종)
- [x] 갤러리 저장 (gal 패키지, 앨범 권한 처리)
- [x] 이미지 공유 (share_plus, PNG 캡처)
- [x] 클립보드 복사
- [x] 히스토리 시스템 (JSON 직렬화, Hive 저장, 중복 제거)
- [x] 히스토리 제한 해제 (보상형 광고: 20개 -> 999개)
- [x] Wi-Fi QR 특수문자 이스케이프 처리
- [x] 실시간 QR 미리보기 (입력 변경 시 자동 업데이트)
- [x] Worker 및 TextEditingController 정상 dispose
- [x] 햅틱 피드백 (QR 생성 시 진동)
- [x] GetX 상태 관리 + 라우팅
- [x] Hive_CE 로컬 저장
- [x] AdMob 광고 (배너 + 전면 + 보상형) + 미디에이션
- [x] 인앱 구매 (프리미엄 광고 제거)
- [x] 다국어 지원 (ko)
- [x] FlexColorScheme 테마 (blueM3)
- [x] 가이드 페이지
- [x] 설정 페이지
- [x] 통계 페이지
- [x] 활동 로그 서비스

## 출시 전 남은 작업

- [ ] AdMob 실제 광고 ID 교체 (현재 테스트 ID)
- [ ] 인앱 구매 상품 ID 등록 (Google Play Console)
- [ ] 앱 아이콘 제작 및 적용 (`dart run flutter_launcher_icons`)
- [ ] 스플래시 화면 제작 및 적용 (`dart run flutter_native_splash:create`)
- [ ] Google Play 스토어 등록 (스크린샷, 설명, 카테고리)
- [ ] Apple App Store 등록
- [ ] 다국어 확장 (en, ja 등)
- [ ] Privacy Policy 페이지 작성
- [ ] ProGuard 규칙 확인 (릴리스 빌드)
- [ ] Firebase Crashlytics 설정 확인
- [ ] 입력 형식 파싱 오류 대응 (특수문자 포함 연락처/URL)
- [ ] 카메라 권한 거부 상태에서 fallback 경로 확인
- [ ] 공유/저장 실패 시 사용자 안내 강화
