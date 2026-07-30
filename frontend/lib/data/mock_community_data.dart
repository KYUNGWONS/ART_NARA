import '../models/community_post.dart';

/// 카테고리 ID (자유 게시판 필터)
const String categoryAll = 'all';

/// 자유 게시판 카테고리
const List<Map<String, String>> communityCategories = [
  {'id': categoryAll, 'label': '전체'},
  {'id': 'question', 'label': '질문'},
  {'id': 'review', 'label': '후기'},
  {'id': 'info', 'label': '정보'},
];

/// Mock 게시물 (한국인 대학생·외국인 여행 소통, 자유 게시판 느낌)
/// 추후 GET /api/community/posts 등으로 교체
final List<CommunityPost> mockCommunityPosts = [
  const CommunityPost(
    id: 'post_001',
    author: '민지',
    authorRole: CommunityAuthorRole.koreanStudent,
    category: 'question',
    title: '이번 주말에 외국인 친구랑 남산 가려는데 추천 코스 있을까요?',
    content:
        '한국 처음 오는 친구 데려가려고요. 낮에 가는 게 나을까요 저녁에 가는 게 나을까요? 맛집도 같이 추천해주시면 감사해요!',
    imageUrl: null,
    likes: 12,
    comments: 8,
    createdAt: '1시간 전',
  ),
  const CommunityPost(
    id: 'post_002',
    author: 'James',
    authorRole: CommunityAuthorRole.foreigner,
    category: 'review',
    title: 'Yesterday I met a Korean student near Hongdae - thank you!',
    content:
        'We had dinner and he showed me a cool bar. Really nice experience. If you are Korean and have time, please show travelers around. We appreciate it so much :)',
    imageUrl:
        'https://images.unsplash.com/photo-1513407030348-c983a97b98d8?w=800',
    likes: 34,
    comments: 15,
    createdAt: '3시간 전',
  ),
  const CommunityPost(
    id: 'post_003',
    author: '준호',
    authorRole: CommunityAuthorRole.koreanStudent,
    category: 'meetup',
    title: '제주도 2박3일 같이 갈 분 구해요 (12월 말)',
    content:
        '저 서울에서 대학 다니는 24살 남자예요. 렌터카 빌릴 예정이고 일정은 같이 정해도 좋아요. 외국인 분이셔도 영어 가능하니까 편하게 연락 주세요!',
    imageUrl: null,
    likes: 7,
    comments: 4,
    createdAt: '5시간 전',
  ),
  const CommunityPost(
    id: 'post_004',
    author: 'Sophie',
    authorRole: CommunityAuthorRole.foreigner,
    category: 'question',
    title: 'Where can I try hanbok and take photos in Seoul?',
    content:
        'I will visit Seoul next month. I want to wear hanbok and take nice photos. Is there a good place not too expensive? Thank you!',
    imageUrl: null,
    likes: 22,
    comments: 19,
    createdAt: '어제',
  ),
  const CommunityPost(
    id: 'post_005',
    author: '수진',
    authorRole: CommunityAuthorRole.koreanStudent,
    category: 'info',
    title: '광화문·종로 쪽 무료 한글교실 있음 (외국인 분들 참고)',
    content:
        '동네에 외국인 분들 위한 한글교실 있어서 공유해요. 매주 토요일 오전 10시, 예약만 하면 됩니다. 관심 있으시면 댓글이나 쪽지 주세요.',
    imageUrl: null,
    likes: 45,
    comments: 6,
    createdAt: '어제',
  ),
  const CommunityPost(
    id: 'post_006',
    author: 'Alex',
    authorRole: CommunityAuthorRole.foreigner,
    category: 'review',
    title: 'Busan trip with a Korean mate - best decision!',
    content:
        'I used ArtNara to find a local student. We went to Gamcheon village and had fresh fish at Jagalchi. He explained everything. 10/10 recommend.',
    imageUrl:
        'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800',
    likes: 58,
    comments: 12,
    createdAt: '2일 전',
  ),
  const CommunityPost(
    id: 'post_007',
    author: '지은',
    authorRole: CommunityAuthorRole.koreanStudent,
    category: 'question',
    title: '외국인 친구한테 선물로 뭐가 좋을까요?',
    content:
        '다음 주에 만나기로 한 친구가 미국에서 왔는데 한국 기념으로 작은 선물 사고 싶어요. 2만 원 안쪽으로 뭐가 좋을까요?',
    imageUrl: null,
    likes: 9,
    comments: 11,
    createdAt: '2일 전',
  ),
  const CommunityPost(
    id: 'post_008',
    author: 'Marco',
    authorRole: CommunityAuthorRole.foreigner,
    category: 'meetup',
    title: 'Looking for someone to visit Gyeongju this weekend',
    content:
        'Hi! I am from Italy. I want to see the historical places in Gyeongju. If any Korean student is free and wants to join, please message me. I can speak a little Korean.',
    imageUrl: null,
    likes: 18,
    comments: 7,
    createdAt: '3일 전',
  ),
  const CommunityPost(
    id: 'post_009',
    author: '현우',
    authorRole: CommunityAuthorRole.koreanStudent,
    category: 'review',
    title: '일본에서 온 친구랑 인사동·북촌 다녀온 후기',
    content:
        '한복 입고 북촌 한옥마을에서 사진 많이 찍었어요. 인사동에서 전통차 마시고 수제청도 사갔음. 다음엔 남산 데려갈 예정!',
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
    likes: 29,
    comments: 5,
    createdAt: '3일 전',
  ),
  const CommunityPost(
    id: 'post_010',
    author: 'Emma',
    authorRole: CommunityAuthorRole.foreigner,
    category: 'info',
    title: 'T-money card - where to buy at Incheon Airport?',
    content:
        'I will arrive at Incheon and need T-money. Can I buy it at the airport? And how much should I charge for 5 days in Seoul? Thanks!',
    imageUrl: null,
    likes: 31,
    comments: 24,
    createdAt: '4일 전',
  ),
];
