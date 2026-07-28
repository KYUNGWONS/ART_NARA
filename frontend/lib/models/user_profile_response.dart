/// GET /users/me 응답 data 필드
class UserProfileData {
  final int userId;
  final String nickname;
  final int? age;
  final String? userType;
  final String? profileImageUrl;
  final String? address;
  final String? addressDetail;
  final String? nationality;
  final List<String> languages;
  final dynamic visitExperience;
  final List<String> interests;
  final int? planningScore;
  final int? activityScore;
  final String? bio;
  final bool profileCompleted;

  const UserProfileData({
    required this.userId,
    required this.nickname,
    this.age,
    this.userType,
    this.profileImageUrl,
    this.address,
    this.addressDetail,
    this.nationality,
    this.languages = const [],
    this.visitExperience,
    this.interests = const [],
    this.planningScore,
    this.activityScore,
    this.bio,
    this.profileCompleted = false,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    // 백엔드 UserDto.Response는 점수를 travelStyle{planning,vibe,role,dynamic}로 중첩해 반환한다.
    final travelStyle = json['travelStyle'] as Map<String, dynamic>?;

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
      // 백엔드는 단일 'region' 필드 사용.
      address: json['address'] as String? ?? json['region'] as String?,
      addressDetail: json['addressDetail'] as String?,
      nationality: json['nationality'] as String?,
      languages:
          (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      visitExperience: json['visitExperience'],
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      planningScore:
          json['planningScore'] as int? ?? travelStyle?['planning'] as int?,
      activityScore:
          json['activityScore'] as int? ?? travelStyle?['dynamic'] as int?,
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
