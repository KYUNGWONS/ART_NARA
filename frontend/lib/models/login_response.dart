/// 로그인 API 응답 data 필드
class LoginResponseData {
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;
  final String? userType;
  final bool profileCompleted;

  const LoginResponseData({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
    this.userType,
    required this.profileCompleted,
  });

  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    return LoginResponseData(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      isNewUser: json['isNewUser'] as bool? ?? false,
      userType: json['userType'] as String?,
      profileCompleted: json['profileCompleted'] as bool? ?? false,
    );
  }
}

/// 로그인 API 전체 응답
class LoginResponse {
  final String code;
  final String? message;
  final LoginResponseData? data;

  const LoginResponse({required this.code, this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>?;
    return LoginResponse(
      code: json['code'] as String? ?? '',
      message: json['message'] as String?,
      data: dataJson != null ? LoginResponseData.fromJson(dataJson) : null,
    );
  }
}
