import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/country_data.dart';
import '../constants/region_data.dart';
import '../providers/locale_provider.dart';
import '../services/auth_api_service.dart';
import '../services/tour_api_service.dart';
import '../services/user_api_service.dart';
import 'main_screen.dart';
import 'role_selection_screen.dart';

class InterestItem {
  final String id;
  final String emoji;
  final Map<AppLanguage, String> label;

  const InterestItem({
    required this.id,
    required this.emoji,
    required this.label,
  });
}

/// 프로필 설정 화면 (피그마 개편: 역할 구분 없는 단일 스크롤 폼).
///
/// 수집 항목 → 백엔드 `POST /api/users` CreateRequest:
/// 이름=displayName, 닉네임=nickname, 나이=age, 현재 거주지역=region,
/// 언어=languages, 관심사=interests, 자기소개=aboutMe,
/// 슬라이더 4개=travelStyle{planning, vibe, role, dynamic}.
class ProfileSetupScreen extends StatefulWidget {
  final UserRole role;
  final String? kakaoProfileImageUrl;
  final String? kakaoNickname;

  const ProfileSetupScreen({
    super.key,
    required this.role,
    this.kakaoProfileImageUrl,
    this.kakaoNickname,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  late TextEditingController _nameController; // 이름 → displayName
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? _profileImageUrl;
  String? _selectedRegion; // 현재 거주지역 → region
  final Set<String> _selectedInterests = {};
  final Set<String> _selectedLanguages = {};

  // 여행 스타일 슬라이더 4개: 각 0~100, 50=중립.
  // 점수 = ((value - 50) * 2) → -100~100 (오른쪽 라벨 = +100)
  double _planningValue = 50; // 즉흥적 ↔ 철저한 계획
  double _vibeValue = 50; // 에너지 넘치는 ↔ 여유로운
  double _roleValue = 50; // 리드하는 편 ↔ 따라가는 편
  double _activityValue = 50; // 조용하게 ↔ 매우 활동적

  /// 회원가입(POST /api/users) 요청 진행 중 여부 (중복 제출 방지)
  bool _isSubmitting = false;

  // 노출 언어 코드 (한국어, 영어, 일본어, 중국어)
  static const List<String> _primaryLanguageCodes = ['ko', 'en', 'ja', 'zh'];

  static const List<InterestItem> _interests = [
    InterestItem(
      id: 'food_cafe',
      emoji: '🍽️',
      label: AppStrings.interestFoodCafe,
    ),
    InterestItem(id: 'local', emoji: '🗺️', label: AppStrings.interestLocal),
    InterestItem(
      id: 'shopping',
      emoji: '🛍️',
      label: AppStrings.interestShopping,
    ),
    InterestItem(id: 'nature', emoji: '🌿', label: AppStrings.interestNature),
    InterestItem(
      id: 'activity',
      emoji: '🪁',
      label: AppStrings.interestTraditionalActivity,
    ),
    InterestItem(id: 'photo', emoji: '📷', label: AppStrings.interestPhoto),
    InterestItem(
      id: 'festival',
      emoji: '🎉',
      label: AppStrings.interestFestival,
    ),
    InterestItem(
      id: 'art_culture',
      emoji: '🎨',
      label: AppStrings.interestArtCulture,
    ),
  ];

  static const Map<String, Color> _interestColors = {
    'food_cafe': AppColors.accent,
    'local': AppColors.primary,
    'shopping': AppColors.purple,
    'nature': AppColors.mint,
    'activity': Color(0xFFA0765A),
    'photo': Color(0xFF00A9B5),
    'festival': AppColors.yellow,
    'art_culture': Color(0xFFE0559A),
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    // 이름은 OAuth 이름으로 프리필, 닉네임은 사용자가 직접 입력
    _nameController = TextEditingController(text: widget.kakaoNickname ?? '');
    _profileImageUrl = widget.kakaoProfileImageUrl;
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// 완료 필수: 이름 + 닉네임 + 유효한 나이 (거주지역·언어·관심사는 선택)
  bool get _isFormComplete {
    final ageText = _ageController.text.trim();
    final age = int.tryParse(ageText) ?? 0;
    final ageValid = ageText.isNotEmpty && age >= 1 && age <= 120;
    return _nameController.text.trim().isNotEmpty &&
        _nicknameController.text.trim().isNotEmpty &&
        ageValid;
  }

  void _toggleInterest(String id) {
    setState(() {
      if (_selectedInterests.contains(id)) {
        _selectedInterests.remove(id);
      } else {
        _selectedInterests.add(id);
      }
    });
  }

  void _toggleLanguage(String code) {
    setState(() {
      if (_selectedLanguages.contains(code)) {
        _selectedLanguages.remove(code);
      } else {
        _selectedLanguages.add(code);
      }
    });
  }

  /// 슬라이더 값(0~100) → 백엔드 점수(-100~100), 50=중립
  int _toScore(double value) => ((value - 50) * 2).round();

  Future<void> _onComplete() async {
    if (!_isFormComplete || _isSubmitting) return;

    final locale = context.read<LocaleProvider>();
    final userType = widget.role == UserRole.koreanStudent
        ? 'KOREAN_STUDENT'
        : 'FOREIGN_TOURIST';

    // 역할에 따라 TourAPI 서비스 언어 결정 (외국인 → 영문 EngService2)
    TourApiService.lang = widget.role == UserRole.foreigner
        ? TourLang.english
        : TourLang.korean;

    setState(() => _isSubmitting = true);

    // POST /api/users (회원가입 / 프로필 설정)
    final result = await UserApiService.createUser(
      email: AuthApiService.userEmail ?? '',
      nickname: _nicknameController.text.trim(),
      displayName: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      userType: userType,
      profileImageUrl: _profileImageUrl,
      region: _selectedRegion ?? '',
      aboutMe: _bioController.text.trim(),
      interests: _selectedInterests.toList(),
      languages: _selectedLanguages.toList(),
      planningScore: _toScore(_planningValue),
      vibeScore: _toScore(_vibeValue),
      roleScore: _toScore(_roleValue),
      activityScore: _toScore(_activityValue),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result == SignupResult.emailConflict) {
      _showSnackBar(locale.tr(AppStrings.signupEmailConflict), AppColors.accent);
      return;
    }
    if (result == SignupResult.failure) {
      _showSnackBar(locale.tr(AppStrings.profileSetupError), AppColors.accent);
      return;
    }

    // 성공 → 완료 안내 후 메인 화면으로 이동 (모든 이전 스택 제거)
    _showSnackBar(locale.tr(AppStrings.profileSetupComplete), AppColors.mint);
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.gowunDodum(fontWeight: FontWeight.w500),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, locale, _) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFF0F5FF), Color(0xFFFFF5F2)],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ─── 헤더 ───
                      Text(
                        locale.tr(AppStrings.profileTitle),
                        style: GoogleFonts.gowunDodum(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        locale.tr(AppStrings.profileSubtitle),
                        style: GoogleFonts.gowunDodum(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // ─── 프로필 사진 ───
                      _buildProfilePhoto(locale),
                      const SizedBox(height: 28),

                      // ─── 이름 & 나이 ───
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _nameController,
                              label: locale.tr(AppStrings.profileName),
                              hint: locale.tr(AppStrings.profileNameHint),
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 100,
                            child: _buildTextField(
                              controller: _ageController,
                              label: locale.tr(AppStrings.profileAge),
                              hint: locale.tr(AppStrings.profileAgeHint),
                              icon: Icons.cake_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),

                      // ─── 여행자 정보 ───
                      _buildSectionHeader(
                        locale.tr(AppStrings.travelerInfoTitle),
                        locale.tr(AppStrings.travelerInfoSubtitle),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _nicknameController,
                        label: locale.tr(AppStrings.profileNickname),
                        hint: locale.tr(AppStrings.profileNicknameInputHint),
                        icon: Icons.badge_outlined,
                        isRequired: false,
                      ),
                      const SizedBox(height: 18),
                      _buildRegionSelector(locale),
                      const SizedBox(height: 18),
                      _buildLanguageSection(locale),
                      const SizedBox(height: 36),
                      const Divider(color: AppColors.lightGrey, height: 1),
                      const SizedBox(height: 28),

                      // ─── 관심사 선택 ───
                      _buildSectionHeader(
                        locale.tr(AppStrings.interestsPick),
                        locale.tr(AppStrings.interestsPickSubtitle),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        locale.tr(AppStrings.interestsPickHelper),
                        style: GoogleFonts.gowunDodum(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 12,
                        children: _interests
                            .map(
                              (i) => _buildInterestChip(
                                interest: i,
                                locale: locale,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 36),
                      const Divider(color: AppColors.lightGrey, height: 1),
                      const SizedBox(height: 28),

                      // ─── 나의 여행 스타일 ───
                      _buildSectionHeader(
                        locale.tr(AppStrings.travelStyleTitle),
                        locale.tr(AppStrings.travelStyleSubtitle),
                      ),
                      const SizedBox(height: 24),
                      _buildStyleSlider(
                        label: locale.tr(AppStrings.planStyleLabel),
                        leftLabel: locale.tr(AppStrings.spontaneousLabel),
                        rightLabel: locale.tr(AppStrings.thoroughPlanLabel),
                        value: _planningValue,
                        onChanged: (v) => setState(() => _planningValue = v),
                      ),
                      const SizedBox(height: 20),
                      _buildStyleSlider(
                        label: locale.tr(AppStrings.vibeLabel),
                        leftLabel: locale.tr(AppStrings.energeticLabel),
                        rightLabel: locale.tr(AppStrings.relaxedLabel),
                        value: _vibeValue,
                        onChanged: (v) => setState(() => _vibeValue = v),
                      ),
                      const SizedBox(height: 20),
                      _buildStyleSlider(
                        label: locale.tr(AppStrings.roleLabel),
                        leftLabel: locale.tr(AppStrings.leadLabel),
                        rightLabel: locale.tr(AppStrings.followLabel),
                        value: _roleValue,
                        onChanged: (v) => setState(() => _roleValue = v),
                      ),
                      const SizedBox(height: 20),
                      _buildStyleSlider(
                        label: locale.tr(AppStrings.activityAmountLabel),
                        leftLabel: locale.tr(AppStrings.quietLabel),
                        rightLabel: locale.tr(AppStrings.veryActiveLabel),
                        value: _activityValue,
                        onChanged: (v) => setState(() => _activityValue = v),
                      ),
                      const SizedBox(height: 36),
                      const Divider(color: AppColors.lightGrey, height: 1),
                      const SizedBox(height: 28),

                      // ─── 자기소개 ───
                      _buildBioField(locale),
                      const SizedBox(height: 32),

                      // ─── 완료 버튼 ───
                      _buildCompleteButton(locale),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.gowunDodum(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.gowunDodum(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfilePhoto(LocaleProvider locale) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // TODO: 사진 변경 기능 (갤러리/카메라)
          },
          child: Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.lightGrey,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null
                    ? const Icon(
                        Icons.person_rounded,
                        size: 44,
                        color: AppColors.grey,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          locale.tr(AppStrings.profilePhoto),
          style: GoogleFonts.gowunDodum(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.gowunDodum(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.gowunDodum(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters ?? [],
          style: GoogleFonts.gowunDodum(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.gowunDodum(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.grey.withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(icon, size: 20, color: AppColors.grey),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ─── 현재 거주지역 드롭다운 ───
  Widget _buildRegionSelector(LocaleProvider locale) {
    final hasValue = _selectedRegion != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.tr(AppStrings.profileCurrentRegion),
          style: GoogleFonts.gowunDodum(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showRegionPicker(locale),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasValue
                        ? _selectedRegion!
                        : locale.tr(AppStrings.regionPickerHint),
                    style: GoogleFonts.gowunDodum(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: hasValue
                          ? AppColors.black
                          : AppColors.grey.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRegionPicker(LocaleProvider locale) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                locale.tr(AppStrings.profileCurrentRegion),
                style: GoogleFonts.gowunDodum(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: koreanRegions.length,
                  itemBuilder: (context, index) {
                    final region = koreanRegions[index];
                    final selected = region == _selectedRegion;
                    return ListTile(
                      title: Text(
                        region,
                        style: GoogleFonts.gowunDodum(
                          fontSize: 15,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? AppColors.primary : AppColors.black,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () {
                        setState(() => _selectedRegion = region);
                        Navigator.of(context).pop();
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

  // ─── 언어 선택 (전원 공통) ───
  Widget _buildLanguageSection(LocaleProvider locale) {
    final displayLanguages = spokenLanguages
        .where((l) => _primaryLanguageCodes.contains(l.code))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🌐', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              locale.tr(AppStrings.profileLanguage),
              style: GoogleFonts.gowunDodum(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          locale.tr(AppStrings.languageSelectHint),
          style: GoogleFonts.gowunDodum(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: displayLanguages
              .map((lang) => _buildLanguageChip(lang))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLanguageChip(LanguageData lang) {
    final isSelected = _selectedLanguages.contains(lang.code);
    return GestureDetector(
      onTap: () => _toggleLanguage(lang.code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.6)
                : AppColors.lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            Text(
              lang.nameNative,
              style: GoogleFonts.gowunDodum(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.darkGrey,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              lang.nameEn,
              style: GoogleFonts.gowunDodum(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestChip({
    required InterestItem interest,
    required LocaleProvider locale,
  }) {
    final isSelected = _selectedInterests.contains(interest.id);
    final color = _interestColors[interest.id] ?? AppColors.primary;

    return GestureDetector(
      onTap: () => _toggleInterest(interest.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : AppColors.lightGrey,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          locale.tr(interest.label),
          style: GoogleFonts.gowunDodum(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? color : AppColors.darkGrey,
          ),
        ),
      ),
    );
  }

  // ─── 여행 스타일 슬라이더 (양끝 라벨 + 원형 핸들) ───
  Widget _buildStyleSlider({
    required String label,
    required String leftLabel,
    required String rightLabel,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.gowunDodum(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.lightGrey,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.12),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leftLabel,
              style: GoogleFonts.gowunDodum(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
            Text(
              rightLabel,
              style: GoogleFonts.gowunDodum(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBioField(LocaleProvider locale) {
    const int maxLength = 100;
    final int currentLength = _bioController.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              locale.tr(AppStrings.bioTitle),
              style: GoogleFonts.gowunDodum(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            Text(
              '$currentLength / $maxLength',
              style: GoogleFonts.gowunDodum(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: currentLength > maxLength
                    ? AppColors.accent
                    : AppColors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bioController,
          maxLines: 4,
          maxLength: maxLength,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.gowunDodum(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
            height: 1.6,
          ),
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                required maxLength,
              }) => null,
          decoration: InputDecoration(
            hintText: locale.tr(AppStrings.bioHint),
            hintStyle: GoogleFonts.gowunDodum(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.grey.withValues(alpha: 0.6),
              height: 1.6,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.all(18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton(LocaleProvider locale) {
    final enabled = _isFormComplete && !_isSubmitting;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? _onComplete : null,
          child: Ink(
            decoration: BoxDecoration(
              gradient: enabled
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.purple],
                    )
                  : null,
              color: enabled ? null : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      _selectedInterests.isNotEmpty
                          ? '${locale.tr(AppStrings.complete)} (${_selectedInterests.length})'
                          : locale.tr(AppStrings.complete),
                      style: GoogleFonts.gowunDodum(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: enabled ? AppColors.white : AppColors.grey,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
