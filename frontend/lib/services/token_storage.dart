import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT 쌍의 보안 저장소.
///
/// SharedPreferences 는 평문 파일이라 토큰 보관에 부적합하다.
/// flutter_secure_storage 는 Android Keystore(EncryptedSharedPreferences)로 암호화한다.
class TokenStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _accessKey = 'artnara_access_token';
  static const _refreshKey = 'artnara_refresh_token';

  static Future<void> save(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  static Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  static Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
