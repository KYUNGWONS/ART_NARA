import '../constants/app_strings.dart';
import '../models/ambassador.dart';

/// Mock 1기 앰배서더 데이터.
///
/// 추후 GET /api/ambassadors 등으로 교체 예정.
/// TODO(서버 연동): 백엔드 앰배서더 API가 준비되면 이 목업을 제거하고 교체한다.
final List<Ambassador> mockAmbassadors = [
  const Ambassador(
    id: 'amb_001',
    name: '김지은',
    university: '연세대학교',
    major: '국제학부',
    generationLabel: '1기 앰배서더',
    profileImageUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
    languages: [AppLanguage.ko, AppLanguage.en, AppLanguage.zh],
    contents: [
      AmbassadorContent(
        emoji: '🎬',
        title: '서울 핫플 브이로그',
        subtitle: '외국인 친구와 함께하는 서울 탐방',
      ),
      AmbassadorContent(
        emoji: '📷',
        title: 'K-Culture 포토 다이어리',
        subtitle: '한국 문화를 담은 일상 사진 콘텐츠',
      ),
      AmbassadorContent(
        emoji: '🎙️',
        title: '언어 교환 팟캐스트',
        subtitle: '한국어 ↔ 영어 대화 실전 에피소드',
      ),
      AmbassadorContent(
        emoji: '✍️',
        title: '유학생 생활 가이드',
        subtitle: '한국 생활 꿀팁과 적응 노하우 공유',
      ),
    ],
  ),
  const Ambassador(
    id: 'amb_002',
    name: '이민준',
    university: '고려대학교',
    major: '경영학과',
    generationLabel: '1기 앰배서더',
    profileImageUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800',
    languages: [AppLanguage.ko, AppLanguage.en],
    contents: [
      AmbassadorContent(
        emoji: '🍜',
        title: '로컬 맛집 탐방기',
        subtitle: '대학가 숨은 맛집 함께 가기',
      ),
      AmbassadorContent(
        emoji: '⚽',
        title: '주말 풋살 모임',
        subtitle: '외국인 친구와 운동하며 친해지기',
      ),
      AmbassadorContent(
        emoji: '📈',
        title: '취업·인턴 인사이트',
        subtitle: '한국 기업 문화와 커리어 이야기',
      ),
    ],
  ),
  const Ambassador(
    id: 'amb_003',
    name: '박서연',
    university: '이화여자대학교',
    major: '미디어커뮤니케이션학부',
    generationLabel: '1기 앰배서더',
    profileImageUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800',
    languages: [AppLanguage.ko, AppLanguage.en, AppLanguage.ja],
    contents: [
      AmbassadorContent(
        emoji: '🎨',
        title: '서울 전시·갤러리 투어',
        subtitle: '감성 가득한 문화 공간 큐레이션',
      ),
      AmbassadorContent(
        emoji: '☕',
        title: '카페 호핑 다이어리',
        subtitle: '동네별 분위기 좋은 카페 기록',
      ),
      AmbassadorContent(
        emoji: '👗',
        title: 'K-패션 룩북',
        subtitle: '계절별 한국 스트릿 패션 소개',
      ),
    ],
  ),
  const Ambassador(
    id: 'amb_004',
    name: '최현우',
    university: '한양대학교',
    major: '소프트웨어학부',
    generationLabel: '1기 앰배서더',
    profileImageUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
    languages: [AppLanguage.ko, AppLanguage.en],
    contents: [
      AmbassadorContent(
        emoji: '💻',
        title: 'IT 용어 한·영 설명',
        subtitle: '개발자를 위한 이중 언어 테크 콘텐츠',
      ),
      AmbassadorContent(
        emoji: '🏋️',
        title: '헬스 루틴 챌린지',
        subtitle: '외국인 친구와 함께하는 운동 기록',
      ),
    ],
  ),
];
