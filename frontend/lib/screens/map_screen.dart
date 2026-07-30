import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../main.dart' show isNaverMapInitialized;
import '../widgets/nearby_artworks_sheet.dart';
import '../models/event_data.dart';
import '../models/region_data.dart';
import '../models/tour_spot.dart';
import '../models/user_location.dart';
import '../providers/locale_provider.dart';
import '../services/location_service.dart';
import '../services/tour_api_service.dart';
import '../widgets/staggered_entrance.dart';
import 'chat_screen.dart';
import 'content_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

// TODO: 백엔드 API 연동 후 실제 데이터로 교체
const List<String> _mockTravelKeywords = [
  '제주도',
  '부산',
  '강릉',
  '맛집',
  '카페',
  '등산',
  '해수욕장',
  '숙소',
  '당일치기',
  '1박2일',
];

// TODO: 백엔드 API 연동 후 실제 인기 검색 순위로 교체
const List<String> _mockPopularRankings = [
  '제주 서귀포',
  '부산 해운대',
  '강릉 경포대',
  '전주 한옥마을',
  '여수 오동도',
];

class _MapScreenState extends State<MapScreen> {
  NaverMapController? _mapController;
  bool _isMapReady = false;
  bool _initFailed = false;
  UserLocation? _selectedUser;
  RegionCluster? _selectedCluster;

  // 검색 바 확장 상태
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  // 현재 줌 레벨 추적
  double _currentZoom = 7;
  RegionLevel _currentLevel = RegionLevel.province;

  // 개별 사용자 마커 표시 여부 (구 단위 클릭 시)
  bool _showingIndividualMarkers = false;

  // TODO: _userLocations → 백엔드 API 또는 bounds 기반 API로 교체
  // TODO: provinceClusters, districtClusters → API 응답 또는 상태 관리 데이터로 교체
  final List<UserLocation> _userLocations = dummyUserLocations;

  @override
  void initState() {
    super.initState();
    if (!isNaverMapInitialized) {
      _tryInitialize();
    }
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _onSearchFocusChange() {
    if (mounted) {
      setState(() => _isSearchExpanded = _searchFocusNode.hasFocus);
    }
  }

  void _collapseSearch() {
    _searchFocusNode.unfocus();
    setState(() => _isSearchExpanded = false);
  }

  Future<void> _tryInitialize() async {
    try {
      await FlutterNaverMap().init(clientId: 'ksrv1pjr10');
      isNaverMapInitialized = true;
      debugPrint('네이버 지도 SDK 재초기화 성공');
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('네이버 지도 SDK 재초기화 실패: $e');
      if (mounted) setState(() => _initFailed = true);
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ─── 지도 준비 완료 ───
  void _onMapReady(NaverMapController controller) {
    _mapController = controller;
    setState(() => _isMapReady = true);
    _renderMarkers();
  }

  // ─── 카메라 변경 감지 ───
  void _onCameraChange(NCameraUpdateReason reason, bool animated) {
    _mapController?.getCameraPosition().then((position) {
      final newZoom = position.zoom;
      final newLevel = newZoom >= zoomThreshold
          ? RegionLevel.district
          : RegionLevel.province;

      if (newLevel != _currentLevel || _currentZoom != newZoom) {
        _currentZoom = newZoom;
        if (newLevel != _currentLevel) {
          _currentLevel = newLevel;
          _showingIndividualMarkers = false;
          _selectedUser = null;
          _selectedCluster = null;
          _renderMarkers();
          setState(() {});
        }
      }
    });
  }

  // ─── 집 주변 작품 매칭 시트 ───
  Future<void> _openNearbyArtworks() async {
    double latitude = 37.5563; // 기본: 홍대입구
    double longitude = 126.9220;
    try {
      final position = await _mapController?.getCameraPosition();
      if (position != null) {
        latitude = position.target.latitude;
        longitude = position.target.longitude;
      }
    } catch (_) {
      // 카메라 조회 실패 시 기본 좌표 사용
    }
    if (!mounted) return;
    showNearbyArtworksSheet(context, latitude: latitude, longitude: longitude);
  }

  // ─── 줌 레벨에 따른 마커 렌더링 ───
  void _renderMarkers() {
    if (_mapController == null) return;
    _mapController!.clearOverlays();

    if (_showingIndividualMarkers) {
      _addIndividualMarkers();
    } else if (_currentLevel == RegionLevel.province) {
      _addClusterMarkers(
        _clustersWithMateCounts(provinceClusters, _userLocations),
      );
    } else {
      _addClusterMarkers(
        _clustersWithMateCounts(districtClusters, _userLocations),
      );
    }
  }

  // ─── 클러스터(지역) 마커 추가 (핀 형태) ───
  /// _userLocations 기준으로 각 지역별 메이트 수를 계산한 클러스터 목록 반환
  List<RegionCluster> _clustersWithMateCounts(
    List<RegionCluster> clusters,
    List<UserLocation> users,
  ) {
    if (users.isEmpty) {
      return clusters
          .map(
            (c) => RegionCluster(
              id: c.id,
              name: c.name,
              lat: c.lat,
              lng: c.lng,
              mateCount: 0,
              level: c.level,
            ),
          )
          .toList();
    }
    final counts = <String, int>{};
    for (final c in clusters) {
      counts[c.id] = 0;
    }
    for (final user in users) {
      RegionCluster? nearest;
      double minDist = double.infinity;
      for (final c in clusters) {
        final d =
            (c.lat - user.lat) * (c.lat - user.lat) +
            (c.lng - user.lng) * (c.lng - user.lng);
        if (d < minDist) {
          minDist = d;
          nearest = c;
        }
      }
      if (nearest != null) {
        counts[nearest.id] = counts[nearest.id]! + 1;
      }
    }
    return clusters
        .map(
          (c) => RegionCluster(
            id: c.id,
            name: c.name,
            lat: c.lat,
            lng: c.lng,
            mateCount: counts[c.id]!,
            level: c.level,
          ),
        )
        .toList();
  }

  void _addClusterMarkers(List<RegionCluster> clusters) {
    if (_mapController == null) return;

    // mateCount가 0인 지역은 제외
    final visible = clusters.where((c) => c.mateCount > 0).toList();
    if (visible.isEmpty) return;

    final maxCount = visible
        .map((c) => c.mateCount)
        .reduce((a, b) => a > b ? a : b);

    for (final cluster in visible) {
      final pinSize = calculatePinSize(
        mateCount: cluster.mateCount,
        maxCountInGroup: maxCount,
      );

      final marker = NMarker(
        id: cluster.id,
        position: NLatLng(cluster.lat, cluster.lng),
        size: pinSize,
        iconTintColor: AppColors.primary,
      );

      marker.setOnTapListener((overlay) {
        _onClusterTapped(cluster);
      });

      _mapController!.addOverlay(marker);
    }
  }

  // ─── 개별 사용자 마커 추가 ───
  void _addIndividualMarkers() {
    if (_mapController == null) return;

    for (final user in _userLocations) {
      final marker = NMarker(
        id: user.userId,
        position: NLatLng(user.lat, user.lng),
        size: const Size(28, 36),
        iconTintColor: AppColors.primary,
      );

      marker.setOnTapListener((overlay) {
        _onUserMarkerTapped(user);
      });

      _mapController!.addOverlay(marker);
    }
  }

  // ─── 클러스터 마커 클릭 ───
  void _onClusterTapped(RegionCluster cluster) {
    setState(() {
      _selectedUser = null;
      _selectedCluster = cluster;
    });

    if (cluster.level == RegionLevel.province) {
      // 광역 핀은 자동으로 시/군/구 단위까지 확대하지 않는다.
      // (임계값을 넘기면 _onCameraChange 가 레벨을 전환해 카드를 닫아버려,
      //  '지역 콘텐츠 보기' 등 카드 버튼을 누를 수 없게 됨)
      // 줌은 그대로 두고 선택 핀만 화면 중앙으로 이동. 상세 확대는
      // 카드의 '이 지역 자세히 보기' 버튼에서만 수행한다.
      _mapController?.updateCamera(
        NCameraUpdate.withParams(target: NLatLng(cluster.lat, cluster.lng)),
      );
    } else {
      // 구 단위 → 개별 마커가 보이도록 확대
      _mapController?.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(cluster.lat, cluster.lng),
          zoom: 14.0,
        ),
      );
    }
  }

  // ─── 개별 사용자 마커 클릭 ───
  void _onUserMarkerTapped(UserLocation user) {
    setState(() {
      _selectedCluster = null;
      _selectedUser = user;
    });
    _mapController?.updateCamera(
      NCameraUpdate.withParams(target: NLatLng(user.lat, user.lng), zoom: 16),
    );
  }

  // ─── 카드 닫기 ───
  void _dismissCards() {
    setState(() {
      _selectedUser = null;
      _selectedCluster = null;
    });
  }

  // ─── 메이트 찾아보기 Bottom Sheet ───
  void _showMateFindBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _MateFindBottomSheet(events: dummyEvents, mates: _userLocations),
    );
  }

  // ─── 지역 콘텐츠 Bottom Sheet (지역기반 관광정보 조회) ───
  void _showRegionContentSheet(RegionCluster cluster) {
    final areaCode = sidoAreaCodes[cluster.id];
    if (areaCode == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TourSpotGridSheet(
        title: cluster.name,
        sectionLabel: '지역 콘텐츠',
        sectionIcon: Icons.location_on_rounded,
        emptyLabel: '표시할 관광 콘텐츠가 없습니다.',
        // 도시 단위로 좁혀야 하는 핀(예: 고양)만 시·군·구 코드 전달
        load: () => TourApiService.fetchSpotsByArea(
          areaCode: areaCode,
          sigunguCode: sigunguCodes[cluster.id],
        ),
      ),
    );
  }

  // ─── 내 주변 (위치기반 locationBasedList2) ───
  void _showNearbySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TourSpotGridSheet(
        title: 'Explore Nearby',
        sectionLabel: '내 주변 관광지',
        sectionIcon: Icons.near_me_rounded,
        emptyLabel: '주변 관광 콘텐츠가 없습니다.',
        load: () async {
          final loc = await LocationService.getCurrentLatLng();
          return TourApiService.fetchNearbySpots(lat: loc.lat, lng: loc.lng);
        },
      ),
    );
  }

  // ─── 키워드 검색 (searchKeyword2) ───
  void _runSearch(String keyword) {
    final q = keyword.trim();
    if (q.isEmpty) return;
    _searchController.text = q;
    _collapseSearch();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TourSpotGridSheet(
        title: "'$q' 검색 결과",
        sectionLabel: '검색 결과',
        sectionIcon: Icons.search_rounded,
        emptyLabel: '검색 결과가 없습니다.',
        load: () => TourApiService.searchByKeyword(q),
      ),
    );
  }

  // ─── 전체 보기 ───
  void _resetView() {
    _dismissCards();
    _showingIndividualMarkers = false;
    _mapController?.updateCamera(
      NCameraUpdate.withParams(target: const NLatLng(36.5, 127.5), zoom: 7),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initFailed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 56,
              color: AppColors.lightGrey,
            ),
            const SizedBox(height: 16),
            Text(
              '지도를 불러올 수 없습니다',
              style: GoogleFonts.gowunDodum(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '네트워크 연결을 확인해 주세요',
              style: GoogleFonts.gowunDodum(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                setState(() => _initFailed = false);
                _tryInitialize();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                '다시 시도',
                style: GoogleFonts.gowunDodum(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!isNaverMapInitialized) {
      return Container(
        color: AppColors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                '지도를 준비하는 중...',
                style: GoogleFonts.gowunDodum(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // 네이버 지도
        NaverMap(
          options: const NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(36.5, 127.5), // 대한민국 중심
              zoom: 7,
            ),
            mapType: NMapType.basic,
            activeLayerGroups: [NLayerGroup.building, NLayerGroup.transit],
            locationButtonEnable: true,
            zoomGesturesFriction: 0.5,
            indoorEnable: true,
          ),
          onMapReady: _onMapReady,
          onMapTapped: (point, latLng) => _dismissCards(),
          onCameraChange: _onCameraChange,
        ),

        // 확장 시 바깥 영역 탭 감지 (바깥 클릭 시 닫힘)
        if (_isSearchExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _collapseSearch,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),

        // 하단: 집 주변 작품 매칭 버튼
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: FilledButton.icon(
              onPressed: _openNearbyArtworks,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.palette_outlined, size: 18),
              label: const Text('집 주변 작품 보기'),
            ),
          ),
        ),

        // 상단: 고정 검색 바 + 확장 레이어
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 검색 바
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(_isSearchExpanded ? 0 : 16),
                        bottomRight: Radius.circular(
                          _isSearchExpanded ? 0 : 16,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      focusNode: _searchFocusNode,
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _runSearch,
                      onChanged: (_) => setState(() {}), // 지우기 버튼 노출 갱신
                      decoration: InputDecoration(
                        hintText: '지역 검색 (예: 서울)',
                        hintStyle: GoogleFonts.gowunDodum(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 22,
                          color: AppColors.grey,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: AppColors.grey,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: GoogleFonts.gowunDodum(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  // 확장 영역: 추천 키워드 + 인기 순위
                  if (_isSearchExpanded)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Travel Keywords
                          Text(
                            '추천 키워드',
                            style: GoogleFonts.gowunDodum(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _mockTravelKeywords.map((keyword) {
                              return GestureDetector(
                                onTap: () => _runSearch(keyword),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    keyword,
                                    style: GoogleFonts.gowunDodum(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          // Popular Rankings
                          Text(
                            '실시간 인기 검색',
                            style: GoogleFonts.gowunDodum(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(_mockPopularRankings.length, (i) {
                            final rank = i + 1;
                            final keyword = _mockPopularRankings[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () => _runSearch(keyword),
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: rank <= 3
                                            ? AppColors.primary
                                            : AppColors.lightGrey,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$rank',
                                        style: GoogleFonts.gowunDodum(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: rank <= 3
                                              ? AppColors.white
                                              : AppColors.grey,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        keyword,
                                        style: GoogleFonts.gowunDodum(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // 지도 로딩 오버레이
        if (!_isMapReady)
          Container(
            color: AppColors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '지도를 불러오는 중...',
                    style: GoogleFonts.gowunDodum(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 좌상단: 현재 뷰 레벨 뱃지 (검색 바 아래, 확장 시 숨김)
        if (_isMapReady && !_isSearchExpanded)
          Positioned(
            top: MediaQuery.of(context).padding.top + 76,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showingIndividualMarkers
                        ? Icons.person_pin_circle_rounded
                        : _currentLevel == RegionLevel.province
                        ? Icons.public_rounded
                        : Icons.location_city_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _showingIndividualMarkers
                        ? '개별 메이트 ${_userLocations.length}명'
                        : _currentLevel == RegionLevel.province
                        ? '광역 단위 보기'
                        : '시/군/구 단위 보기',
                    style: GoogleFonts.gowunDodum(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 우상단: 전국 보기 버튼 (검색 바 아래, 확장 시 숨김)
        if (_isMapReady && !_isSearchExpanded)
          Positioned(
            top: MediaQuery.of(context).padding.top + 76,
            right: 16,
            child: GestureDetector(
              onTap: _resetView,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.zoom_out_map_rounded,
                  size: 22,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ),

        // 하단 중앙: Explore Nearby (위치기반 조회) — 카드/검색 미표시 시에만 노출
        if (_isMapReady &&
            !_isSearchExpanded &&
            _selectedCluster == null &&
            _selectedUser == null)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _showNearbySheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.near_me_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Explore Nearby',
                        style: GoogleFonts.gowunDodum(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 하단: 클러스터 정보 카드
        if (_selectedCluster != null && _selectedUser == null)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: _buildClusterCard(_selectedCluster!),
          ),

        // 하단: 개별 사용자 정보 카드
        if (_selectedUser != null)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: _buildUserCard(_selectedUser!),
          ),
      ],
    );
  }

  // ─── 클러스터 정보 카드 ───
  Widget _buildClusterCard(RegionCluster cluster) {
    final isProvince = cluster.level == RegionLevel.province;
    // 광역 단위이고 지역 코드가 매핑된 경우에만 관광 콘텐츠 조회 버튼 노출
    final hasAreaContent = isProvince && sidoAreaCodes.containsKey(cluster.id);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (isProvince) ...[
                // 광역(도/시)일 때만 지역 아이콘 표시
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('📍', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cluster.name,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '메이트 ${cluster.mateCount}명',
                          style: GoogleFonts.gowunDodum(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _dismissCards,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 액션 버튼
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                if (isProvince) {
                  // 광역 → 구 단위로 줌인
                  _mapController?.updateCamera(
                    NCameraUpdate.withParams(
                      target: NLatLng(cluster.lat, cluster.lng),
                      zoom: 11.5,
                    ),
                  );
                } else {
                  // 구 단위 → 메이트 찾아보기 Bottom Sheet
                  setState(() => _selectedCluster = null);
                  _showMateFindBottomSheet(context);
                }
              },
              icon: Icon(
                isProvince
                    ? Icons.zoom_in_rounded
                    : Icons.person_search_rounded,
                size: 20,
              ),
              label: Text(
                isProvince ? '이 지역 자세히 보기' : '메이트 찾아보기',
                style: GoogleFonts.gowunDodum(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          // 지역 콘텐츠 보기 (지역기반 관광정보 조회)
          if (hasAreaContent) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () {
                  _dismissCards();
                  _showRegionContentSheet(cluster);
                },
                icon: const Icon(Icons.photo_library_rounded, size: 20),
                label: Text(
                  '지역 콘텐츠 보기',
                  style: GoogleFonts.gowunDodum(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── 개별 사용자 정보 카드 ───
  Widget _buildUserCard(UserLocation user) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: user.profileImageUrl != null
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null
                    ? Text(
                        user.nickname[0],
                        style: GoogleFonts.gowunDodum(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nickname,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('🎓', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '한국인 대학생',
                            style: GoogleFonts.gowunDodum(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _dismissCards,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  user.address,
                  style: GoogleFonts.gowunDodum(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                // TODO: 사용자 프로필 상세 페이지 이동
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                '프로필 보기',
                style: GoogleFonts.gowunDodum(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 메이트 찾아보기 Bottom Sheet ───
class _MateFindBottomSheet extends StatefulWidget {
  final List<EventData> events;
  final List<UserLocation> mates;

  const _MateFindBottomSheet({required this.events, required this.mates});

  @override
  State<_MateFindBottomSheet> createState() => _MateFindBottomSheetState();
}

class _MateFindBottomSheetState extends State<_MateFindBottomSheet> {
  void _showMateProfileModal(BuildContext context, UserLocation mate) {
    showDialog(
      context: context,
      builder: (context) => _MateProfileDetailModal(mate: mate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // 핸들
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 섹션 타이틀: 행사
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.event_rounded,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '이 지역 행사',
                                  style: GoogleFonts.gowunDodum(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    // A. 행사 슬라이더 (좌/우 스와이프)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: widget.events.length,
                          itemBuilder: (context, index) {
                            final event = widget.events[index];
                            return _EventCard(event: event);
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Divider(height: 1, color: AppColors.lightGrey),
                          const SizedBox(height: 16),
                          // 섹션 타이틀: 메이트
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.people_rounded,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '메이트 목록',
                                  style: GoogleFonts.gowunDodum(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    // B. 메이트 리스트 (위/아래 스크롤)
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final mate = widget.mates[index];
                          return _MateListItem(
                            mate: mate,
                            onTap: () => _showMateProfileModal(context, mate),
                          );
                        }, childCount: widget.mates.length),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── 메이트 프로필 상세 모달 ───
class _MateProfileDetailModal extends StatelessWidget {
  final UserLocation mate;

  const _MateProfileDetailModal({required this.mate});

  static const Map<String, Map<AppLanguage, String>> _interestLabels = {
    'travel': AppStrings.interestTravel,
    'food': AppStrings.interestFood,
    'activity': AppStrings.interestActivity,
    'culture': AppStrings.interestCulture,
    'cafe': AppStrings.interestCafe,
    'unique': AppStrings.interestUnique,
  };

  static const Map<String, Color> _interestColors = {
    'travel': AppColors.primary,
    'food': AppColors.accent,
    'activity': AppColors.mint,
    'culture': AppColors.purple,
    'cafe': Color(0xFFA0765A),
    'unique': AppColors.yellow,
  };

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 프로필 사진
                    Center(
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage: mate.profileImageUrl != null
                            ? NetworkImage(mate.profileImageUrl!)
                            : null,
                        child: mate.profileImageUrl == null
                            ? Text(
                                mate.nickname[0],
                                style: GoogleFonts.gowunDodum(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 이름
                    Center(
                      child: Text(
                        mate.nickname,
                        style: GoogleFonts.gowunDodum(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    if (mate.age != null) ...[
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          '${mate.age}세',
                          style: GoogleFonts.gowunDodum(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    // 자기소개
                    Text(
                      locale.tr(AppStrings.bioTitle),
                      style: GoogleFonts.gowunDodum(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mate.introduction ?? locale.tr(AppStrings.bioHint),
                      style: GoogleFonts.gowunDodum(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 관심사
                    Text(
                      locale.tr(AppStrings.interestsTitle),
                      style: GoogleFonts.gowunDodum(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: mate.interests.map((id) {
                        final label = _interestLabels[id];
                        final color = _interestColors[id] ?? AppColors.primary;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: color.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            label != null ? locale.tr(label) : id,
                            style: GoogleFonts.gowunDodum(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // 여행 성향: 계획성
                    Text(
                      locale.tr(AppStrings.planningLabel),
                      style: GoogleFonts.gowunDodum(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          locale.tr(AppStrings.spontaneous),
                          style: GoogleFonts.gowunDodum(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: LinearProgressIndicator(
                              value: (mate.planningScore + 100) / 200,
                              backgroundColor: AppColors.lightGrey,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        Text(
                          locale.tr(AppStrings.planned),
                          style: GoogleFonts.gowunDodum(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        mate.planningScore >= 0
                            ? '계획형 +${mate.planningScore}'
                            : '즉흥형 ${mate.planningScore}',
                        style: GoogleFonts.gowunDodum(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 여행 성향: 활발도
                    Text(
                      locale.tr(AppStrings.activityLevelLabel),
                      style: GoogleFonts.gowunDodum(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          locale.tr(AppStrings.quiet),
                          style: GoogleFonts.gowunDodum(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: LinearProgressIndicator(
                              value: (mate.activityScore + 100) / 200,
                              backgroundColor: AppColors.lightGrey,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.mint,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        Text(
                          locale.tr(AppStrings.veryActive),
                          style: GoogleFonts.gowunDodum(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        mate.activityScore < 0
                            ? '조용한 편 ${mate.activityScore}'
                            : mate.activityScore > 0
                            ? '활발한 편 +${mate.activityScore}'
                            : '보통',
                        style: GoogleFonts.gowunDodum(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 대화하기 버튼 → 채팅 화면으로 이동
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => ChatScreen(mate: mate),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    '대화하기',
                    style: GoogleFonts.gowunDodum(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 행사 카드 (슬라이더용) ───
class _EventCard extends StatelessWidget {
  final EventData event;

  const _EventCard({required this.event});

  static Widget _eventImagePlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.15),
      child: const Center(
        child: Icon(
          Icons.celebration_rounded,
          size: 40,
          color: AppColors.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이미지 (imageUrl 있으면 표시, 없거나 로드 실패 시 placeholder)
            Expanded(
              flex: 2,
              child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                  ? Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => _eventImagePlaceholder(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    )
                  : _eventImagePlaceholder(),
            ),
            // 타이틀, 장소
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.place,
                            style: GoogleFonts.gowunDodum(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 메이트 리스트 아이템 ───
class _MateListItem extends StatelessWidget {
  final UserLocation mate;
  final VoidCallback onTap;

  const _MateListItem({required this.mate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: mate.profileImageUrl != null
                  ? NetworkImage(mate.profileImageUrl!)
                  : null,
              child: mate.profileImageUrl == null
                  ? Text(
                      mate.nickname[0],
                      style: GoogleFonts.gowunDodum(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mate.nickname,
                    style: GoogleFonts.gowunDodum(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mate.introduction ?? '자기소개가 없습니다.',
                    style: GoogleFonts.gowunDodum(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 관광 콘텐츠 그리드 Bottom Sheet (지역 콘텐츠 / 검색 결과 공용) ───
class _TourSpotGridSheet extends StatefulWidget {
  final String title;
  final String sectionLabel;
  final IconData sectionIcon;
  final String emptyLabel;

  /// 시트 마운트 시 1회 실행되어 그리드에 표시할 관광 콘텐츠를 불러온다.
  final Future<List<TourSpot>> Function() load;

  const _TourSpotGridSheet({
    required this.title,
    required this.sectionLabel,
    required this.sectionIcon,
    required this.emptyLabel,
    required this.load,
  });

  @override
  State<_TourSpotGridSheet> createState() => _TourSpotGridSheetState();
}

class _TourSpotGridSheetState extends State<_TourSpotGridSheet> {
  late final Future<List<TourSpot>> _spotsFuture = widget.load();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // 헤더: 제목 + 닫기
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.gowunDodum(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 섹션 타이틀
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      widget.sectionIcon,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.sectionLabel,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 콘텐츠 그리드 (FutureBuilder)
              Expanded(
                child: FutureBuilder<List<TourSpot>>(
                  future: _spotsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                      );
                    }
                    final spots = snapshot.data ?? const <TourSpot>[];
                    if (spots.isEmpty) {
                      return Center(
                        child: Text(
                          widget.emptyLabel,
                          style: GoogleFonts.gowunDodum(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey,
                          ),
                        ),
                      );
                    }
                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),
                      itemCount: spots.length,
                      itemBuilder: (context, index) {
                        return StaggeredEntrance(
                          index: index,
                          child: _TourSpotCard(spot: spots[index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── 지역 콘텐츠 카드 (관광지) ───
class _TourSpotCard extends StatelessWidget {
  final TourSpot spot;

  const _TourSpotCard({required this.spot});

  static Widget _imagePlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: const Center(
        child: Icon(Icons.photo_rounded, size: 36, color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = spot.firstImage;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ContentDetailScreen(spot: spot),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.6)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 대표 이미지
              Expanded(
                flex: 3,
                child: image != null && image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                      )
                    : _imagePlaceholder(),
              ),
              // 제목 + 주소
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spot.title,
                        style: GoogleFonts.gowunDodum(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 13,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                spot.addr1,
                                style: GoogleFonts.gowunDodum(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
