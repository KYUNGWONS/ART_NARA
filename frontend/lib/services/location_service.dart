import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// 디바이스 현재 위치 조회 헬퍼.
///
/// 위치 권한이 거부되었거나 위치 서비스가 꺼져 있거나 오류가 나면
/// 기본 좌표(서울시청)를 반환하여 화면 흐름이 끊기지 않도록 한다.
class LocationService {
  /// 서울시청 좌표 (위치 사용 불가 시 폴백)
  static const double _fallbackLat = 37.5665;
  static const double _fallbackLng = 126.9780;

  /// 현재 위치 (위도, 경도)를 반환. 실패 시 서울 기본 좌표를 반환한다.
  static Future<({double lat, double lng})> getCurrentLatLng() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[Location] 위치 서비스 비활성 - 기본 좌표 사용');
        return (lat: _fallbackLat, lng: _fallbackLng);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('[Location] 위치 권한 거부 - 기본 좌표 사용');
        return (lat: _fallbackLat, lng: _fallbackLng);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      debugPrint(
        '[Location] 현재 위치: ${position.latitude}, ${position.longitude}',
      );
      return (lat: position.latitude, lng: position.longitude);
    } catch (e) {
      debugPrint('[Location] 위치 조회 실패 - 기본 좌표 사용: $e');
      return (lat: _fallbackLat, lng: _fallbackLng);
    }
  }
}
