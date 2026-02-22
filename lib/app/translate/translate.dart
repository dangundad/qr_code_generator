import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Languages extends Translations {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ko'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      // Common
      'settings': 'Settings',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'share': 'Share',
      'reset': 'Reset',
      'done': 'Done',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'no_data': 'No data',
      'copy': 'Copy',

      // App
      'app_name': 'QR Generator',
      'fill_form': 'Fill in the form to generate a QR code',
      'history': 'History',
      'no_history': 'No history yet',
      'clear_all': 'Clear All',
      'copied': 'Copied',
      'qr_empty_error': 'Please fill in the required fields first',

      // Colors
      'fg_color': 'QR Color',
      'bg_color': 'Background',

      // URL
      'url_label': 'URL',

      // Text
      'text_label': 'Text',
      'text_hint': 'Enter any text...',

      // WiFi
      'wifi_ssid': 'Network Name (SSID)',
      'wifi_password': 'Password',
      'wifi_security': 'Security Type',

      // Contact
      'contact_name': 'Full Name',
      'contact_phone': 'Phone Number',
      'contact_email': 'Email',
      'contact_org': 'Organization',

      // Email
      'email_to': 'To (Email)',
      'email_subject': 'Subject',
      'email_subject_hint': 'Enter subject...',
      'email_body': 'Message',
      'email_body_hint': 'Enter message...',
    },
    'ko': {
      // 공통
      'settings': '설정',
      'save': '저장',
      'cancel': '취소',
      'delete': '삭제',
      'edit': '편집',
      'share': '공유',
      'reset': '초기화',
      'done': '완료',
      'ok': '확인',
      'yes': '예',
      'no': '아니오',
      'error': '오류',
      'success': '성공',
      'loading': '로딩 중...',
      'no_data': '데이터 없음',
      'copy': '복사',

      // 앱
      'app_name': 'QR 생성기',
      'fill_form': '폼을 입력하면 QR 코드가 생성됩니다',
      'history': '히스토리',
      'no_history': '아직 생성 기록이 없습니다',
      'clear_all': '전체 삭제',
      'copied': '복사됨',
      'qr_empty_error': '필수 항목을 먼저 입력해 주세요',

      // 색상
      'fg_color': 'QR 색상',
      'bg_color': '배경색',

      // URL
      'url_label': 'URL 주소',

      // 텍스트
      'text_label': '텍스트',
      'text_hint': '텍스트를 입력하세요...',

      // WiFi
      'wifi_ssid': '네트워크 이름 (SSID)',
      'wifi_password': '비밀번호',
      'wifi_security': '보안 방식',

      // 연락처
      'contact_name': '이름',
      'contact_phone': '전화번호',
      'contact_email': '이메일',
      'contact_org': '회사/조직',

      // 이메일
      'email_to': '받는 사람 (이메일)',
      'email_subject': '제목',
      'email_subject_hint': '제목을 입력하세요...',
      'email_body': '내용',
      'email_body_hint': '내용을 입력하세요...',
    },
  };
}
