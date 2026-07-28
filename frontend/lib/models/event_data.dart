// TODO: GET /api/events 등 API 응답으로 교체 (기초 단위 행사 데이터)

/// 행사 정보 모델
class EventData {
  final String id;
  final String title;
  final String place;
  final String? imageUrl;

  const EventData({
    required this.id,
    required this.title,
    required this.place,
    this.imageUrl,
  });
}

/// 기초 단위 행사 더미 데이터
final List<EventData> dummyEvents = [
  const EventData(
    id: 'evt_001',
    title: '한강 페스티벌',
    place: '서울 여의도 한강공원',
    imageUrl:
        'https://cdn.eyesmag.com/content/uploads/posts/2024/04/30/02-ffee5fbd-a26d-4fe2-acbd-929dea8d336e.jpg',
  ),
  const EventData(
    id: 'evt_002',
    title: '종로 야시장 투어',
    place: '서울 종로구 청계천',
    imageUrl:
        'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
  ),
  const EventData(
    id: 'evt_003',
    title: '성수 카페 투어',
    place: '서울 성동구 성수동',
    imageUrl:
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
  ),
  const EventData(
    id: 'evt_004',
    title: '이태원 맛집 탐방',
    place: '서울 용산구 이태원',
    imageUrl:
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
  ),
  const EventData(
    id: 'evt_005',
    title: '홍대 거리 아트 투어',
    place: '서울 마포구 홍대입구',
    imageUrl:
        'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=400',
  ),
];
