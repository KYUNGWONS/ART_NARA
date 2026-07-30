import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/tour_detail.dart';
import '../models/tour_spot.dart';

/// 관광정보 서비스 언어(역할 기반): 한국인 대학생 → 국문, 외국인 → 영문.
enum TourLang { korean, english }

/// 한국관광공사 관광정보 서비스 GW 클라이언트 (KorService2 / EngService2).
///
/// ⚠️ 프로토타입: serviceKey가 앱에 포함된 채 data.go.kr을 직접 호출한다.
/// TODO(서버 연동): 백엔드 프록시(/api/recommend-regions)를 거치도록 변경하고
/// 이 클래스의 직접 호출/ mock 폴백을 제거.
class TourApiService {
  /// 현재 사용할 관광정보 서비스 언어. 역할 확정 시(프로필 설정/로그인) 설정한다.
  /// 외국인 → [TourLang.english](EngService2), 그 외 → [TourLang.korean](KorService2).
  static TourLang lang = TourLang.korean;

  /// 현재 언어에 해당하는 서비스 base path.
  static String get _basePath =>
      lang == TourLang.english ? tourApiEngBasePath : tourApiKorBasePath;

  /// 위치 기반(`locationBasedList2`)으로 주변 관광지를 조회한다.
  ///
  /// [lat]/[lng]는 디바이스 현재 위치, [radius]는 검색 반경(m, 최대 20000).
  /// 대표 이미지가 있는 항목만 최대 10개 반환한다.
  /// 요청 실패 시 mock 데이터를 반환한다.
  static Future<List<TourSpot>> fetchNearbySpots({
    required double lat,
    required double lng,
    int radius = 10000,
  }) async {
    try {
      // 필수 파라미터: MobileOS, MobileApp, mapX(경도), mapY(위도), radius, serviceKey
      // (_type=json 은 JSON 응답을 받기 위해, numOfRows/pageNo 는 개수 제한용)
      final uri =
          Uri.https(tourApiHost, '$_basePath/locationBasedList2', {
            'serviceKey': tourApiServiceKey,
            'MobileOS': 'IOS',
            'MobileApp': 'ArtNara',
            'mapX': lng.toString(),
            'mapY': lat.toString(),
            'radius': radius.toString(),
            '_type': 'json',
            'numOfRows': '20',
            'pageNo': '1',
          });

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        debugPrint('[TourAPI] locationBasedList2 실패: ${response.statusCode}');
        return _mockSpotsForOffline();
      }

      final spots = _parseSpots(response.body);
      if (spots.isEmpty) {
        debugPrint('[TourAPI] 결과 없음 - mock 사용');
        return _mockSpotsForOffline();
      }
      debugPrint('[TourAPI] locationBasedList2 성공: ${spots.length}건');
      return spots;
    } catch (e) {
      debugPrint('[TourAPI] 요청 실패 (서버 미연결 시 mock 사용): $e');
      return _mockSpotsForOffline();
    }
  }

  /// 지역 기반(`areaBasedList2`)으로 특정 지역의 관광 콘텐츠를 조회한다.
  ///
  /// [areaCode]는 한국관광공사 지역 코드(예: 서울=1, 부산=6, 제주=39, 경기=31).
  /// [sigunguCode]를 주면 시·군·구 단위로 좁힌다(예: 경기=31 + 고양시=2).
  /// [contentTypeId]를 주면 관광타입(12:관광지, 39:음식점 등)으로 필터링한다.
  /// 대표 이미지가 있는 항목만 최대 10개 반환한다.
  /// 요청 실패 시 mock 데이터를 반환한다.
  static Future<List<TourSpot>> fetchSpotsByArea({
    required String areaCode,
    String? sigunguCode,
    String? contentTypeId,
    int numOfRows = 20,
  }) async {
    try {
      // 필수 파라미터: MobileOS, MobileApp, serviceKey
      // areaCode 로 시·도를, sigunguCode 로 시·군·구를 지정.
      // arrange=O 로 "제목순 + 대표이미지 필수" 정렬.
      final uri = Uri.https(tourApiHost, '$_basePath/areaBasedList2', {
        'serviceKey': tourApiServiceKey,
        'MobileOS': 'IOS',
        'MobileApp': 'ArtNara',
        'areaCode': areaCode,
        'sigunguCode': ?sigunguCode,
        'arrange': 'O', // 제목순 + 대표이미지가 반드시 있는 항목
        'contentTypeId': ?contentTypeId,
        '_type': 'json',
        'numOfRows': numOfRows.toString(),
        'pageNo': '1',
      });

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        debugPrint('[TourAPI] areaBasedList2 실패: ${response.statusCode}');
        return _mockSpotsForOffline();
      }

      final spots = _parseSpots(response.body);
      if (spots.isEmpty) {
        debugPrint('[TourAPI] 지역 결과 없음 - mock 사용');
        return _mockSpotsForOffline();
      }
      debugPrint('[TourAPI] areaBasedList2 성공: ${spots.length}건');
      return spots;
    } catch (e) {
      debugPrint('[TourAPI] 지역 요청 실패 (서버 미연결 시 mock 사용): $e');
      return _mockSpotsForOffline();
    }
  }

  /// 키워드 검색(`searchKeyword2`)으로 관광 콘텐츠를 조회한다.
  ///
  /// [keyword]는 검색어(예: '서울'). 대표 이미지가 있는 항목만 [numOfRows] 중
  /// 최대 [numOfRows]개 반환한다. 요청 실패/빈 결과 시 mock 데이터를 반환한다.
  static Future<List<TourSpot>> searchByKeyword(
    String keyword, {
    int numOfRows = 30,
  }) async {
    try {
      // 필수 파라미터: MobileOS, MobileApp, keyword, serviceKey
      // keyword는 Uri.https가 자동으로 URL 인코딩한다. arrange=O → 대표이미지 필수.
      final uri = Uri.https(tourApiHost, '$_basePath/searchKeyword2', {
        'serviceKey': tourApiServiceKey,
        'MobileOS': 'IOS',
        'MobileApp': 'ArtNara',
        'keyword': keyword,
        'arrange': 'O',
        '_type': 'json',
        'numOfRows': numOfRows.toString(),
        'pageNo': '1',
      });

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        debugPrint('[TourAPI] searchKeyword2 실패: ${response.statusCode}');
        return _mockSpotsForOffline();
      }

      final spots = _parseSpots(response.body, limit: numOfRows);
      if (spots.isEmpty) {
        debugPrint('[TourAPI] 검색 결과 없음 - mock 사용');
        return _mockSpotsForOffline();
      }
      debugPrint('[TourAPI] searchKeyword2 성공: ${spots.length}건');
      return spots;
    } catch (e) {
      debugPrint('[TourAPI] 검색 요청 실패 (서버 미연결 시 mock 사용): $e');
      return _mockSpotsForOffline();
    }
  }

  /// 행사정보 조회(`searchFestival2`)로 진행/예정 축제를 조회한다.
  ///
  /// [eventStartDate](YYYYMMDD) 이후 진행되는 행사를 반환하며, 미지정 시 오늘.
  /// 대표 이미지가 있는 항목만 반환하고 행사 시작일 오름차순으로 정렬한다.
  /// 요청 실패/빈 결과 시 mock 데이터를 반환한다.
  static Future<List<TourSpot>> searchFestivals({
    String? eventStartDate,
    int numOfRows = 20,
  }) async {
    try {
      final start = eventStartDate ?? _todayYmd();
      final uri = Uri.https(tourApiHost, '$_basePath/searchFestival2', {
        'serviceKey': tourApiServiceKey,
        'MobileOS': 'IOS',
        'MobileApp': 'ArtNara',
        'eventStartDate': start,
        'arrange': 'O', // 제목순 + 대표이미지 필수
        '_type': 'json',
        'numOfRows': numOfRows.toString(),
        'pageNo': '1',
      });

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        debugPrint('[TourAPI] searchFestival2 실패: ${response.statusCode}');
        return _mockFestivalsForOffline();
      }

      final festivals = _parseSpots(response.body, limit: numOfRows)
        ..sort(
          (a, b) => (a.eventStartDate ?? '').compareTo(b.eventStartDate ?? ''),
        );
      if (festivals.isEmpty) {
        debugPrint('[TourAPI] 행사 결과 없음 - mock 사용');
        return _mockFestivalsForOffline();
      }
      debugPrint('[TourAPI] searchFestival2 성공: ${festivals.length}건');
      return festivals;
    } catch (e) {
      debugPrint('[TourAPI] 행사 요청 실패 (서버 미연결 시 mock 사용): $e');
      return _mockFestivalsForOffline();
    }
  }

  /// 오늘 날짜를 YYYYMMDD 문자열로 반환.
  static String _todayYmd() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '${n.year}$m$d';
  }

  /// 상세정보 조회를 합쳐 반환한다.
  /// (`detailCommon2` 공통정보 + `detailImage2` 이미지 + `detailIntro2` 소개정보)
  ///
  /// [contentId]는 콘텐츠 ID, [contentTypeId]가 있으면 소개정보도 조회한다.
  /// [fallbackTitle]/[fallbackImage]는 목록 카드에서 받은 값으로, 응답 일부가
  /// 비어 있을 때 보완용으로 쓴다. 요청 실패 시 mock 데이터를 반환한다.
  static Future<TourDetail> fetchDetail({
    required String contentId,
    String? contentTypeId,
    String? fallbackTitle,
    String? fallbackImage,
  }) async {
    try {
      // 세 API를 병렬 호출 (소개정보는 contentTypeId가 있을 때만)
      final responses = await Future.wait([
        http.get(_detailUri('detailCommon2', {'contentId': contentId})),
        http.get(
          _detailUri('detailImage2', {
            'contentId': contentId,
            'imageYN': 'Y',
            'numOfRows': '20',
          }),
        ),
        if (contentTypeId != null)
          http.get(
            _detailUri('detailIntro2', {
              'contentId': contentId,
              'contentTypeId': contentTypeId,
            }),
          ),
      ]);

      final common = responses[0].statusCode == 200
          ? _firstItemMap(responses[0].body)
          : null;
      if (common == null) {
        debugPrint('[TourAPI] detailCommon2 결과 없음 - mock 사용');
        return _mockDetailForOffline(
          contentId: contentId,
          contentTypeId: contentTypeId,
          title: fallbackTitle,
          image: fallbackImage,
        );
      }

      final images = responses[1].statusCode == 200
          ? _imageUrls(responses[1].body)
          : const <String>[];
      final intro = (contentTypeId != null && responses[2].statusCode == 200)
          ? _firstItemMap(responses[2].body)
          : null;

      // 대표 이미지(firstimage) + 상세 이미지들을 합치고 중복 제거
      final imageUrls = <String>[];
      final firstImage = _str(common['firstimage']);
      if (firstImage.isNotEmpty) imageUrls.add(firstImage);
      for (final u in images) {
        if (!imageUrls.contains(u)) imageUrls.add(u);
      }
      if (imageUrls.isEmpty && (fallbackImage ?? '').isNotEmpty) {
        imageUrls.add(fallbackImage!);
      }

      final title = _str(common['title']);
      final detail = TourDetail(
        contentId: contentId,
        contentTypeId: contentTypeId,
        title: title.isNotEmpty ? title : (fallbackTitle ?? ''),
        addr1: _nullIfEmpty(_str(common['addr1'])),
        period: intro != null ? _festivalPeriod(contentTypeId, intro) : null,
        infoItems: intro != null ? _introInfo(contentTypeId, intro) : const [],
        overview: _nullIfEmpty(_stripHtml(_str(common['overview']))),
        imageUrls: imageUrls,
      );
      debugPrint(
        '[TourAPI] detail 성공: ${detail.title} '
        '(img ${imageUrls.length}, info ${detail.infoItems.length})',
      );
      return detail;
    } catch (e) {
      debugPrint('[TourAPI] 상세 요청 실패 (서버 미연결 시 mock 사용): $e');
      return _mockDetailForOffline(
        contentId: contentId,
        contentTypeId: contentTypeId,
        title: fallbackTitle,
        image: fallbackImage,
      );
    }
  }

  /// 응답 본문에서 대표 이미지가 있는 관광지 목록([limit]개)을 파싱한다.
  static List<TourSpot> _parseSpots(String body, {int limit = 10}) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return const [];

    // 응답 래퍼(`response`)가 있을 수도, 없을 수도 있어 둘 다 처리한다.
    final root = decoded['response'] is Map<String, dynamic>
        ? decoded['response'] as Map<String, dynamic>
        : decoded;

    final header = root['header'];
    if (header is Map<String, dynamic>) {
      final code = (header['resultCode'] ?? '').toString();
      // 정상 코드는 0000. 그 외에는 메시지를 남기고 비운다.
      if (code.isNotEmpty && code != '0000') {
        debugPrint('[TourAPI] resultCode=$code, msg=${header['resultMsg']}');
        return const [];
      }
    }

    final bodyMap = root['body'];
    if (bodyMap is! Map<String, dynamic>) return const [];

    // 결과가 없으면 items가 빈 문자열("")로 올 수 있다.
    final items = bodyMap['items'];
    if (items is! Map<String, dynamic>) return const [];

    final item = items['item'];
    final List<Map<String, dynamic>> rawList;
    if (item is List) {
      rawList = item.whereType<Map<String, dynamic>>().toList();
    } else if (item is Map<String, dynamic>) {
      // 결과가 단건이면 객체로 내려온다.
      rawList = [item];
    } else {
      return const [];
    }

    return rawList
        .map(TourSpot.fromJson)
        .where((s) => (s.firstImage ?? '').isNotEmpty && s.title.isNotEmpty)
        .take(limit)
        .toList();
  }

  /// 서버/네트워크 미연결 시 추천 지역 화면 테스트용 mock 응답.
  /// TODO(서버 연동): 실제 연동 후 이 메서드 삭제.
  static List<TourSpot> _mockSpotsForOffline() {
    debugPrint('[TourAPI] mock 추천 관광지 응답 사용');
    return const [
      TourSpot(
        contentId: 'mock_001',
        title: '경복궁',
        addr1: '서울특별시 종로구 사직로 161',
        firstImage:
            'https://images.unsplash.com/photo-1538485399081-7191377e8241?w=600',
      ),
      TourSpot(
        contentId: 'mock_002',
        title: '북촌한옥마을',
        addr1: '서울특별시 종로구 계동길 37',
        firstImage:
            'https://images.unsplash.com/photo-1601618890948-2e7f7e8b9f9b?w=600',
      ),
      TourSpot(
        contentId: 'mock_003',
        title: '청계천',
        addr1: '서울특별시 종로구 창신동',
        firstImage:
            'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=600',
      ),
      TourSpot(
        contentId: 'mock_004',
        title: '남산서울타워',
        addr1: '서울특별시 용산구 남산공원길 105',
        firstImage:
            'https://images.unsplash.com/photo-1538669715315-155098f0fb1d?w=600',
      ),
    ];
  }

  /// 서버/네트워크 미연결 시 "다가오는 축제" 섹션 테스트용 mock 응답.
  /// TODO(서버 연동): 실제 연동 후 이 메서드 삭제.
  static List<TourSpot> _mockFestivalsForOffline() {
    debugPrint('[TourAPI] mock 행사 응답 사용');
    return const [
      TourSpot(
        contentId: 'mock_fes_001',
        title: '서울 세계불꽃축제',
        addr1: '서울특별시 영등포구 여의동로 330',
        firstImage:
            'https://images.unsplash.com/photo-1467810563316-b5476525c0f9?w=600',
        contentTypeId: '15',
        eventStartDate: '20261004',
        eventEndDate: '20261004',
      ),
      TourSpot(
        contentId: 'mock_fes_002',
        title: '강릉단오제',
        addr1: '강원특별자치도 강릉시 단오장길 1',
        firstImage:
            'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=600',
        contentTypeId: '15',
        eventStartDate: '20260615',
        eventEndDate: '20260622',
      ),
      TourSpot(
        contentId: 'mock_fes_003',
        title: '부산 불꽃축제',
        addr1: '부산광역시 수영구 광안해변로 219',
        firstImage:
            'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600',
        contentTypeId: '15',
        eventStartDate: '20261107',
        eventEndDate: '20261108',
      ),
    ];
  }

  // ─── 상세정보 조회 보조 ───

  /// 상세 API용 Uri 빌더 (공통 파라미터 + operation별 파라미터).
  static Uri _detailUri(String operation, Map<String, String> params) {
    return Uri.https(tourApiHost, '$_basePath/$operation', {
      'serviceKey': tourApiServiceKey,
      'MobileOS': 'IOS',
      'MobileApp': 'ArtNara',
      '_type': 'json',
      ...params,
    });
  }

  /// 응답 래퍼(response→header→body→items)를 벗겨 `items.item` 노드를 반환.
  static Object? _itemsNode(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return null;
    final root = decoded['response'] is Map<String, dynamic>
        ? decoded['response'] as Map<String, dynamic>
        : decoded;
    final header = root['header'];
    if (header is Map<String, dynamic>) {
      final code = (header['resultCode'] ?? '').toString();
      if (code.isNotEmpty && code != '0000') {
        debugPrint('[TourAPI] resultCode=$code, msg=${header['resultMsg']}');
        return null;
      }
    }
    final bodyMap = root['body'];
    if (bodyMap is! Map<String, dynamic>) return null;
    final items = bodyMap['items'];
    if (items is! Map<String, dynamic>) return null;
    return items['item'];
  }

  /// 단건 응답(detailCommon2/detailIntro2)의 첫 item을 Map으로 반환.
  static Map<String, dynamic>? _firstItemMap(String body) {
    final item = _itemsNode(body);
    if (item is List) {
      final maps = item.whereType<Map<String, dynamic>>();
      return maps.isEmpty ? null : maps.first;
    }
    if (item is Map<String, dynamic>) return item;
    return null;
  }

  /// detailImage2 응답에서 originimgurl 목록을 반환.
  static List<String> _imageUrls(String body) {
    final item = _itemsNode(body);
    final List<Map<String, dynamic>> list;
    if (item is List) {
      list = item.whereType<Map<String, dynamic>>().toList();
    } else if (item is Map<String, dynamic>) {
      list = [item];
    } else {
      return const [];
    }
    return list
        .map((m) => _str(m['originimgurl']))
        .where((u) => u.isNotEmpty)
        .toList();
  }

  /// contentTypeId별 핵심 정보(라벨:값)를 추출한다(빈 값 제외).
  static List<TourDetailInfo> _introInfo(
    String? contentTypeId,
    Map<String, dynamic> intro,
  ) {
    // 국문/영문 contentTypeId를 공통 종류로 정규화해 필드를 고른다.
    // (필드명은 KorService2/EngService2 동일, 값만 언어가 다름)
    final List<({String label, String key})> fields;
    switch (contentTypeKind(contentTypeId)) {
      case TourContentKind.touristSpot: // 관광지
        fields = [
          (label: '이용시간', key: 'usetime'),
          (label: '쉬는날', key: 'restdate'),
          (label: '문의', key: 'infocenter'),
        ];
      case TourContentKind.culture: // 문화시설
        fields = [
          (label: '이용시간', key: 'usetimeculture'),
          (label: '쉬는날', key: 'restdateculture'),
          (label: '문의', key: 'infocenterculture'),
        ];
      case TourContentKind.festival: // 축제공연행사 (기간은 period로 별도 표시)
        fields = [
          (label: '장소', key: 'eventplace'),
          (label: '이용요금', key: 'usetimefestival'),
          (label: '공연시간', key: 'playtime'),
        ];
      case TourContentKind.course: // 여행코스
        fields = [
          (label: '코스거리', key: 'distance'),
          (label: '소요시간', key: 'taketime'),
        ];
      case TourContentKind.leports: // 레포츠
        fields = [
          (label: '이용시간', key: 'usetimeleports'),
          (label: '쉬는날', key: 'restdateleports'),
          (label: '문의', key: 'infocenterleports'),
        ];
      case TourContentKind.lodging: // 숙박
        fields = [
          (label: '체크인', key: 'checkintime'),
          (label: '체크아웃', key: 'checkouttime'),
          (label: '예약', key: 'reservationlodging'),
        ];
      case TourContentKind.shopping: // 쇼핑
        fields = [
          (label: '영업시간', key: 'opentime'),
          (label: '쉬는날', key: 'restdateshopping'),
          (label: '문의', key: 'infocentershopping'),
        ];
      case TourContentKind.restaurant: // 음식점
        fields = [
          (label: '영업시간', key: 'opentimefood'),
          (label: '쉬는날', key: 'restdatefood'),
          (label: '대표메뉴', key: 'firstmenu'),
        ];
      case TourContentKind.transport:
      case null:
        fields = const [];
    }
    final result = <TourDetailInfo>[];
    for (final f in fields) {
      final v = _stripHtml(_str(intro[f.key]));
      if (v.isNotEmpty) result.add(TourDetailInfo(label: f.label, value: v));
    }
    return result;
  }

  /// 축제 기간 "YY.MM.DD — YY.MM.DD" 문자열 (축제가 아니면 null).
  /// 국문(15)/영문(85) 모두 종류로 판정한다.
  static String? _festivalPeriod(
    String? contentTypeId,
    Map<String, dynamic> intro,
  ) {
    if (contentTypeKind(contentTypeId) != TourContentKind.festival) return null;
    final start = _fmtDate(_str(intro['eventstartdate']));
    final end = _fmtDate(_str(intro['eventenddate']));
    if (start == null && end == null) return null;
    if (start != null && end != null) return '$start — $end';
    return start ?? end;
  }

  /// "YYYYMMDD" → "YY.MM.DD" (형식이 다르면 원본/그대로).
  static String? _fmtDate(String yyyymmdd) {
    final s = yyyymmdd.trim();
    if (s.isEmpty) return null;
    if (s.length != 8) return s;
    return '${s.substring(2, 4)}.${s.substring(4, 6)}.${s.substring(6, 8)}';
  }

  /// 응답 문자열의 HTML 태그/엔티티를 정리한다(<br>은 줄바꿈으로).
  static String _stripHtml(String s) {
    if (s.isEmpty) return s;
    return s
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  static String _str(Object? v) => (v ?? '').toString().trim();
  static String? _nullIfEmpty(String s) => s.isEmpty ? null : s;

  /// 서버/네트워크 미연결 시 상세 화면 테스트용 mock 응답.
  /// TODO(서버 연동): 실제 연동 후 이 메서드 삭제.
  static TourDetail _mockDetailForOffline({
    required String contentId,
    String? contentTypeId,
    String? title,
    String? image,
  }) {
    debugPrint('[TourAPI] mock 상세 응답 사용');
    return TourDetail(
      contentId: contentId,
      contentTypeId: contentTypeId,
      title: (title ?? '').isNotEmpty ? title! : '관광 콘텐츠',
      addr1: '서울특별시',
      infoItems: const [
        TourDetailInfo(label: '이용시간', value: '09:00 ~ 18:00'),
        TourDetailInfo(label: '문의', value: '02-000-0000'),
      ],
      overview: '상세 정보를 불러오지 못했습니다. 네트워크 연결을 확인해 주세요. (서버 연동 전 임시 화면)',
      imageUrls: [
        if ((image ?? '').isNotEmpty)
          image!
        else
          'https://images.unsplash.com/photo-1538485399081-7191377e8241?w=800',
      ],
    );
  }
}
