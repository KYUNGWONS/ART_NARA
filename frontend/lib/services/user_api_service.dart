import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/user_profile_response.dart';
import 'auth_api_service.dart';

/// 회원가입(POST /api/users) 결과 분기용
enum SignupResult { success, emailConflict, failure }

/// 유저 타입 선택 및 프로필 저장/조회 API
class UserApiService {
  /// GET /api/users/me
  /// 내 프로필 조회. 실패하면 null — mock 프로필로 장애를 가리지 않는다
  /// (가짜 userId 가 캐시되면 채팅 senderId 까지 오염된다).
  static Future<UserProfileResponse?> getMe() async {
    final token = AuthApiService.accessToken;
    if (token == null || token.isEmpty) {
      debugPrint('[UserAPI] GET /api/users/me 실패: accessToken 없음');
      return null;
    }
    try {
      final uri = Uri.parse('$apiBaseUrl/api/users/me');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final map = jsonDecode(response.body) as Map<String, dynamic>?;
        if (map != null) {
          final res = UserProfileResponse.fromJson(map);
          // 채팅 등 userId가 필요한 API를 위해 내 userId 캐시.
          if (res.data != null) {
            AuthApiService.userId = res.data!.userId;
          }
          debugPrint('[UserAPI] GET /api/users/me 성공');
          return res;
        }
      }
      debugPrint('[UserAPI] GET /api/users/me 실패: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('[UserAPI] GET /api/users/me 요청 실패: $e');
      return null;
    }
  }

  /// PATCH /api/users/me
  /// 부분 프로필 수정. 백엔드 UpdateRequest 스키마에 맞춰
  /// {nickname, displayName, region, aboutMe, interests}만 전송한다.
  /// (age·userType은 이 엔드포인트에서 수정하지 않는다.)
  static Future<bool> updateMe({
    required String nickname,
    String? displayName,
    String? region,
    String? introduction,
    required List<String> interests,
  }) async {
    final bodyMap = <String, dynamic>{
      'nickname': nickname,
      'interests': interests,
    };
    if (displayName != null && displayName.isNotEmpty) {
      bodyMap['displayName'] = displayName;
    }
    if (region != null && region.isNotEmpty) bodyMap['region'] = region;
    if (introduction != null && introduction.isNotEmpty) {
      bodyMap['aboutMe'] = introduction;
    }

    debugPrint('[UserAPI] PATCH /api/users/me body: ${jsonEncode(bodyMap)}');

    final token = AuthApiService.accessToken;
    if (token == null || token.isEmpty) {
      debugPrint('[UserAPI] PATCH /api/users/me 실패: accessToken 없음');
      return false;
    }

    try {
      final uri = Uri.parse('$apiBaseUrl/api/users/me');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final body = jsonEncode(bodyMap);
      final response = await http.patch(uri, headers: headers, body: body);

      debugPrint(
        '[UserAPI] PATCH /api/users/me 응답 statusCode: ${response.statusCode}',
      );
      if (response.body.isNotEmpty) {
        debugPrint('[UserAPI] PATCH /api/users/me 응답 body: ${response.body}');
      }

      if (response.statusCode == 200) {
        debugPrint('[UserAPI] PATCH /api/users/me 성공');
        return true;
      }
      debugPrint('[UserAPI] PATCH /api/users/me 실패: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('[UserAPI] PATCH /api/users/me 요청 실패: $e');
      return false;
    }
  }

  /// POST /api/users
  /// 회원가입(프로필 설정). 로그인으로 발급받은 JWT(Authorization)와 함께
  /// 프로필 설정 화면에서 입력한 정보를 전송해 사용자를 생성한다.
  ///
  /// 반환: 200/201 → success, 409 → emailConflict, 그 외(400/401/500)·네트워크 오류 → failure.
  static Future<SignupResult> createUser({
    required String email,
    required String nickname,
    required String displayName,
    required int age,
    required String userType,
    String? profileImageUrl,
    required String region,
    String? aboutMe,
    required List<String> interests,
  }) async {
    final bodyMap = <String, dynamic>{
      'email': email,
      'nickname': nickname,
      'displayName': displayName,
      'age': age,
      'userType': userType,
      'profileImageUrl': profileImageUrl ?? '',
      'region': region,
      'aboutMe': aboutMe ?? '',
      'interests': interests,
    };

    debugPrint('[UserAPI] POST /api/users email: $email, userType: $userType');
    debugPrint('[UserAPI] POST /api/users nickname: $nickname, age: $age');
    debugPrint('[UserAPI] POST /api/users body: ${jsonEncode(bodyMap)}');

    // 401 진단: 실제로 어떤 토큰이 붙는지 확인 (mock/빈 토큰이면 인증 실패의 원인)
    final token = AuthApiService.accessToken;
    final tokenInfo = (token == null || token.isEmpty)
        ? '없음 ⚠️ (로그인에서 토큰이 발급되지 않음)'
        : '${token.length}자 (${token.length <= 12 ? token : '${token.substring(0, 12)}…'})';
    debugPrint('[UserAPI] POST /api/users 인증 토큰: $tokenInfo');

    try {
      final uri = Uri.parse('$apiBaseUrl/api/users');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(bodyMap),
      );

      debugPrint(
        '[UserAPI] POST /api/users 응답 statusCode: ${response.statusCode}',
      );
      if (response.body.isNotEmpty) {
        debugPrint('[UserAPI] POST /api/users 응답 body: ${response.body}');
      }

      if (response.statusCode == 409) {
        debugPrint('[UserAPI] POST /api/users 실패: 이미 가입된 이메일');
        return SignupResult.emailConflict;
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[UserAPI] POST /api/users 성공');
        return SignupResult.success;
      }
      // 400/401/500 등 → 실패 (더 이상 mock 성공으로 가리지 않음)
      debugPrint('[UserAPI] POST /api/users 실패: ${response.statusCode}');
      debugPrint('[UserAPI] POST /api/users 응답 헤더: ${response.headers}');
      return SignupResult.failure;
    } catch (e) {
      debugPrint('[UserAPI] POST /api/users 요청 실패 (네트워크/파싱 오류): $e');
      return SignupResult.failure;
    }
  }
}
