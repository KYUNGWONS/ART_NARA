import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import '../constants/dust_tokens.dart';
import 'art_home_feed_screen.dart' show formatPrice;
import '../main.dart' show isKakaoMapInitialized, kakaoMapUnavailableReason;
import '../models/nearby_artwork.dart';
import '../services/artwork_api_service.dart';
import '../widgets/nearby_artworks_sheet.dart';
import 'artwork_detail_screen.dart';

/// 지도 탭 — 집 주변 작품 매칭 (아트나라 전용).
/// 지도 위에 판매 중인 작품 마커를 찍고, 마커를 탭하면 하단 카드로 상세 진입한다.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _defaultCenter = LatLng(37.5563, 126.9220); // 홍대입구

  final _api = const ArtworkApiService();
  KakaoMapController? _mapController;
  final List<Poi> _pois = [];
  List<NearbyArtwork> _artworks = const [];
  NearbyArtwork? _selected;
  bool _loading = false;
  bool _cameraMoved = false;

  Future<void> _loadArtworks(double latitude, double longitude) async {
    setState(() {
      _loading = true;
      _cameraMoved = false;
    });
    try {
      final artworks =
          await _api.fetchNearby(latitude: latitude, longitude: longitude);
      if (!mounted) return;
      setState(() => _artworks = artworks);
      _renderMarkers();
    } catch (_) {
      if (mounted) _showMessage('주변 작품을 불러오지 못했어요');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 작품 마커(POI) 공용 스타일 — 브랜드 teal 라벨 텍스트.
  static final _poiStyle = PoiStyle(
    textStyle: const [
      PoiTextStyle(
        size: 26,
        color: DustColors.brandPrimary,
        stroke: 2,
        strokeColor: Colors.white,
      ),
    ],
  );

  Future<void> _renderMarkers() async {
    final controller = _mapController;
    if (controller == null) return;
    // 이전 마커를 지우고 새 결과로 다시 그린다.
    for (final poi in _pois) {
      await controller.labelLayer.removePoi(poi);
    }
    _pois.clear();
    for (final artwork in _artworks) {
      final poi = await controller.labelLayer.addPoi(
        LatLng(artwork.latitude, artwork.longitude),
        style: _poiStyle,
        text: artwork.title,
        onClick: () => setState(() => _selected = artwork),
      );
      _pois.add(poi);
    }
  }

  Future<void> _searchHere() async {
    final controller = _mapController;
    if (controller == null) return;
    try {
      final position = await controller.getCameraPosition();
      await _loadArtworks(
          position.position.latitude, position.position.longitude);
    } catch (_) {
      await _loadArtworks(_defaultCenter.latitude, _defaultCenter.longitude);
    }
  }

  Future<void> _openNearbySheet() async {
    double latitude = _defaultCenter.latitude;
    double longitude = _defaultCenter.longitude;
    try {
      final position = await _mapController?.getCameraPosition();
      if (position != null) {
        latitude = position.position.latitude;
        longitude = position.position.longitude;
      }
    } catch (_) {
      // 카메라 조회 실패 시 기본 좌표 사용
    }
    if (!mounted) return;
    showNearbyArtworksSheet(context, latitude: latitude, longitude: longitude);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    // 지도 SDK 를 못 쓰는 환경(카카오 키 미설정)에서는 목록 폴백을 위해 바로 조회한다.
    if (!isKakaoMapInitialized) {
      _loadArtworks(_defaultCenter.latitude, _defaultCenter.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isKakaoMapInitialized) {
      return _buildListFallback();
    }

    return Stack(
      children: [
        KakaoMap(
          option: const KakaoMapOption(
            position: _defaultCenter,
            zoomLevel: 15,
          ),
          onMapReady: (controller) {
            _mapController = controller;
            _loadArtworks(_defaultCenter.latitude, _defaultCenter.longitude);
          },
          onMapClick: (point, latLng) {
            if (_selected != null) setState(() => _selected = null);
          },
          onCameraMoveEnd: (position, gestureType) {
            if (!_cameraMoved && !_loading) {
              setState(() => _cameraMoved = true);
            }
          },
        ),

        // 상단: 이 지역에서 검색
        if (_cameraMoved)
          Positioned(
            top: DustSpacing.md,
            left: 0,
            right: 0,
            child: Center(
              child: FilledButton.icon(
                onPressed: _loading ? null : _searchHere,
                style: FilledButton.styleFrom(
                  backgroundColor: DustColors.bgSurface,
                  foregroundColor: DustColors.brandPrimary,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                      horizontal: DustSpacing.md, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DustRadius.full),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('이 지역에서 검색',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ),

        if (_loading)
          const Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: DustColors.brandPrimary),
              ),
            ),
          ),

        // 하단: 선택 작품 카드 or 집 주변 작품 버튼
        Positioned(
          left: DustSpacing.md,
          right: DustSpacing.md,
          bottom: DustSpacing.lg,
          child: _selected != null
              ? _ArtworkMapCard(
                  artwork: _selected!,
                  onClose: () => setState(() => _selected = null),
                  onOpen: () {
                    final artwork = _selected!;
                    setState(() => _selected = null);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ArtworkDetailScreen(artworkId: artwork.id),
                      ),
                    );
                  },
                )
              : Center(
                  child: FilledButton.icon(
                    onPressed: _openNearbySheet,
                    style: FilledButton.styleFrom(
                      backgroundColor: DustColors.brandPrimary,
                      foregroundColor: DustColors.textOnBrand,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DustRadius.full),
                      ),
                    ),
                    icon: const Icon(Icons.palette_outlined, size: 18),
                    label: Text(
                      _artworks.isEmpty
                          ? '집 주변 작품 보기'
                          : '집 주변 작품 ${_artworks.length}개 보기',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// 마커 탭 시 뜨는 작품 요약 카드
/// 지도 SDK 없이도 '집 주변 작품'을 쓸 수 있게 하는 거리순 목록 폴백.
extension _MapFallback on _MapScreenState {
  Widget _buildListFallback() {
    return Container(
      color: DustColors.bgCanvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(DustSpacing.lg, DustSpacing.xs,
                DustSpacing.lg, DustSpacing.sm),
            padding: const EdgeInsets.all(DustSpacing.sm),
            decoration: BoxDecoration(
              color: DustColors.bgInfo,
              borderRadius: BorderRadius.circular(DustRadius.sm),
            ),
            child: Text(
              // 실제 사유를 보여준다 — 키 문제가 아니라 에뮬레이터 미지원일 수 있다.
              '${kakaoMapUnavailableReason ?? '지도를 불러오지 못해 목록으로 보여드려요.'}'
              ' 기준 위치에서 가까운 순입니다.',
              style: DustText.caption,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: DustColors.brandPrimary))
                : _artworks.isEmpty
                ? const Center(
                    child: Text('주변에 등록된 작품이 없어요',
                        style: DustText.caption))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(DustSpacing.lg, 0,
                        DustSpacing.lg, DustSpacing.lg),
                    itemCount: _artworks.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: DustSpacing.sm),
                    itemBuilder: (context, index) {
                      final artwork = _artworks[index];
                      return _ArtworkMapCard(
                        artwork: artwork,
                        showClose: false,
                        onClose: () {},
                        onOpen: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ArtworkDetailScreen(artworkId: artwork.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ArtworkMapCard extends StatelessWidget {
  const _ArtworkMapCard({
    required this.artwork,
    required this.onClose,
    required this.onOpen,
    this.showClose = true,
  });

  final NearbyArtwork artwork;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  /// 목록 폴백에서는 닫기 버튼이 필요 없다.
  final bool showClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(DustSpacing.md),
        decoration: BoxDecoration(
          color: DustColors.bgSurface,
          borderRadius: BorderRadius.circular(DustRadius.md),
          border: Border.all(color: DustColors.borderSoft),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: DustColors.bgSubtle,
                borderRadius: BorderRadius.circular(DustRadius.sm),
              ),
              child: const Icon(Icons.image_outlined,
                  size: 22, color: DustColors.textSecondary),
            ),
            const SizedBox(width: DustSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(artwork.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: DustColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('${artwork.artistName} · ${artwork.address}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: DustColors.textSecondary)),
                  const SizedBox(height: 3),
                  Text(
                    '${artwork.auction ? '현재가' : '정가'} ₩${formatPrice(artwork.price)} · ${artwork.distanceKm}km',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DustColors.brandPrimary),
                  ),
                ],
              ),
            ),
            if (showClose)
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close,
                    size: 18, color: DustColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
