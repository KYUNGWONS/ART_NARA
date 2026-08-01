/// GET /users/me 응답 data 필드
class UserProfileData {
  final int userId;
  final String nickname;
  final int? age;
  final String? userType;
  final String? profileImageUrl;
  final String? region;
  final List<String> interests;
  final String? bio;
  final bool profileCompleted;

  const UserProfileData({
    required this.userId,
    required this.nickname,
    this.age,
    this.userType,
    this.profileImageUrl,
    this.region,
    this.interests = const [],
    this.bio,
    this.profileCompleted = false,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    // 백엔드 userType enum(KOREAN_STUDENT/FOREIGN_TOURIST)을 앱 내부 표기로 정규화.
    // 앱은 외국인을 'FOREIGNER'로 다루므로 FOREIGN_TOURIST를 매핑한다.
    final rawUserType = json['userType'] as String?;
    final userType = rawUserType == 'FOREIGN_TOURIST' ? 'FOREIGNER' : rawUserType;

    return UserProfileData(
      // 백엔드는 'id', 구 프론트 목업은 'userId' → 둘 다 수용.
      userId: json['userId'] as int? ?? json['id'] as int? ?? 0,
      nickname: json['nickname'] as String? ?? '',
      age: json['age'] as int?,
      userType: userType,
      profileImageUrl: json['profileImageUrl'] as String?,
      // 백엔드는 시·도 한글 라벨("서울특별시")을 region 으로 돌려준다.
      region: json['region'] as String?,
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      // 백엔드는 'aboutMe' 필드 사용.
      bio: json['bio'] as String? ?? json['aboutMe'] as String?,
      profileCompleted: json['profileCompleted'] as bool? ?? false,
    );
  }
}

/// GET /users/me 전체 응답
class UserProfileResponse {
  final String code;
  final String? message;
  final UserProfileData? data;

  const UserProfileResponse({required this.code, this.message, this.data});

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>?;
    return UserProfileResponse(
      code: json['code'] as String? ?? '',
      message: json['message'] as String?,
      data: dataJson != null ? UserProfileData.fromJson(dataJson) : null,
    );
  }
}
