# UniTrip Frontend

한국인 대학생과 외국인 관광객을 매칭하여 함께 로컬 여행을 즐기는 서비스 **UniTrip**의 Flutter 앱입니다.

## Getting Started

### Prerequisites
- Flutter SDK (^3.10.8)
- Dart SDK

### Installation

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # 앱 진입점
├── constants/
│   ├── app_colors.dart       # 앱 컬러 팔레트
│   └── app_text_styles.dart  # 텍스트 스타일 정의
├── screens/
│   ├── landing_screen.dart   # 초기 랜딩 화면 (로고 + Start 버튼)
│   └── onboarding_screen.dart # 서비스 소개 온보딩 화면
├── widgets/                  # 공통 위젯
└── models/                   # 데이터 모델
```

## Features (Current)
- 앱 랜딩 화면 (로고 + Start 버튼)
- 서비스 소개 온보딩 (3페이지 슬라이드)
