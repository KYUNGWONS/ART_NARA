import '../constants/app_strings.dart';

/// 앰배서더가 진행 중인 콘텐츠 한 건.
class AmbassadorContent {
  /// 목록 좌측 라운드 사각형에 표시할 이모지 (예: "🎬").
  final String emoji;

  /// 콘텐츠 제목 (예: "서울 핫플 브이로그").
  final String title;

  /// 콘텐츠 한 줄 설명 (예: "외국인 친구와 함께하는 서울 탐방").
  final String subtitle;

  const AmbassadorContent({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

/// KNOT 앰배서더 한 명.
///
/// 홈 화면 쇼케이스(원형 프로필)와 상세 화면(대형 사진 + 프로필 + 콘텐츠)에서
/// 공통으로 사용한다. 현재는 [mockAmbassadors]로만 채워지며, 추후 서버 연동 예정.
class Ambassador {
  final String id;

  /// 이름 (예: "김지은").
  final String name;

  /// 학교 (예: "연세대학교").
  final String university;

  /// 학과 (예: "국제학부").
  final String major;

  /// 기수 라벨 (예: "1기 앰배서더").
  final String generationLabel;

  /// 프로필 사진 URL. 홈 아바타와 상세 대형 사진에 공용으로 쓴다.
  final String profileImageUrl;

  /// 구사 언어. 칩 표시는 [AppStrings.languageLabels]로 변환한다.
  final List<AppLanguage> languages;

  /// 진행 중인 콘텐츠 목록.
  final List<AmbassadorContent> contents;

  const Ambassador({
    required this.id,
    required this.name,
    required this.university,
    required this.major,
    required this.generationLabel,
    required this.profileImageUrl,
    required this.languages,
    required this.contents,
  });
}
