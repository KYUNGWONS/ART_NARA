import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/dust_tokens.dart';
import '../constants/region_data.dart';
import '../services/auth_api_service.dart';
import '../services/user_api_service.dart';
import 'main_screen.dart';
import 'role_selection_screen.dart';

/// 관심 장르 — 작품 카테고리와 동일한 축을 쓴다.
const _genres = ['회화', '조각', '디지털', '사진', '일러스트', '공예'];

/// 프로필 설정 (작가/컬렉터 공용) — DUST-ART 스타일.
///
/// 백엔드 `POST /api/users` 계약은 여행 시절 필드(languages, travelStyle 점수)를
/// 아직 요구하므로 기본값으로 채워 보낸다. TODO(서버 정리): 아트나라 전용 계약으로 축소.
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

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late final TextEditingController _nicknameController;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();

  String? _region;
  final Set<String> _selectedGenres = {};
  bool _submitting = false;

  bool get _isArtist => widget.role == UserRole.koreanStudent;

  @override
  void initState() {
    super.initState();
    _nicknameController =
        TextEditingController(text: widget.kakaoNickname ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nicknameController.text.trim().isEmpty) {
      _showMessage('활동명을 입력해주세요');
      return;
    }
    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age <= 0) {
      _showMessage('나이를 입력해주세요');
      return;
    }
    if (_region == null) {
      _showMessage('활동 지역을 선택해주세요');
      return;
    }
    setState(() => _submitting = true);

    final result = await UserApiService.createUser(
      email: AuthApiService.userEmail ?? '',
      nickname: _nicknameController.text.trim(),
      displayName: _nameController.text.trim().isEmpty
          ? _nicknameController.text.trim()
          : _nameController.text.trim(),
      age: age,
      // 백엔드 enum 유지: 작가=KOREAN_STUDENT, 컬렉터=FOREIGN_TOURIST
      userType: _isArtist ? 'KOREAN_STUDENT' : 'FOREIGN_TOURIST',
      profileImageUrl: widget.kakaoProfileImageUrl,
      region: _region!,
      aboutMe: _bioController.text.trim(),
      interests: _selectedGenres.toList(),
      languages: const ['한국어'],
      planningScore: 50,
      vibeScore: 50,
      roleScore: 50,
      activityScore: 50,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result == SignupResult.emailConflict) {
      _showMessage('이미 가입된 이메일입니다');
      return;
    }
    if (result == SignupResult.failure) {
      _showMessage('프로필 저장에 실패했습니다. 다시 시도해주세요');
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DustColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: DustColors.bgCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left,
              size: 28, color: DustColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${_isArtist ? '작가' : '컬렉터'} 프로필 설정',
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: DustColors.brandPrimary)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            DustSpacing.lg, DustSpacing.xs, DustSpacing.lg, DustSpacing.lg),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DustColors.bgSubtle,
                border: Border.all(color: DustColors.borderSoft),
              ),
              child: widget.kakaoProfileImageUrl == null
                  ? const Icon(Icons.person_outline,
                      size: 40, color: DustColors.textSecondary)
                  : Image.network(widget.kakaoProfileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                          Icons.person_outline,
                          size: 40,
                          color: DustColors.textSecondary)),
            ),
          ),
          const SizedBox(height: DustSpacing.lg),
          const _FieldLabel('활동명 (닉네임)'),
          _input(_nicknameController,
              _isArtist ? '작가명으로 사용됩니다' : '닉네임을 입력하세요'),
          const SizedBox(height: DustSpacing.md),
          const _FieldLabel('이름 (선택)'),
          _input(_nameController, '실명을 입력하면 인증에 사용됩니다'),
          const SizedBox(height: DustSpacing.md),
          const _FieldLabel('나이'),
          _input(_ageController, '예: 24', number: true),
          const SizedBox(height: DustSpacing.md),
          const _FieldLabel('활동 지역'),
          DropdownButtonFormField<String>(
            initialValue: _region,
            items: koreanRegions
                .map((region) => DropdownMenuItem(
                    value: region,
                    child:
                        Text(region, style: const TextStyle(fontSize: 14))))
                .toList(),
            onChanged: (value) => setState(() => _region = value),
            hint: const Text('지역을 선택해주세요',
                style: TextStyle(
                    fontSize: 13, color: DustColors.textSecondary)),
            decoration: _decoration(),
          ),
          const SizedBox(height: DustSpacing.md),
          _FieldLabel(_isArtist ? '작가 소개' : '취향 소개'),
          TextField(
            controller: _bioController,
            maxLines: 3,
            style:
                const TextStyle(fontSize: 14, color: DustColors.textPrimary),
            decoration: _decoration(
                hint: _isArtist
                    ? '작업 세계와 주로 다루는 주제를 소개해주세요'
                    : '어떤 작품을 좋아하는지 알려주세요'),
          ),
          const SizedBox(height: DustSpacing.md),
          _FieldLabel(_isArtist ? '주요 장르' : '관심 장르'),
          Wrap(
            spacing: DustSpacing.xs,
            runSpacing: DustSpacing.xs,
            children: _genres.map((genre) {
              final active = _selectedGenres.contains(genre);
              return GestureDetector(
                onTap: () => setState(() {
                  if (active) {
                    _selectedGenres.remove(genre);
                  } else {
                    _selectedGenres.add(genre);
                  }
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: active
                        ? DustColors.brandPrimary
                        : DustColors.bgSurface,
                    borderRadius: BorderRadius.circular(DustRadius.full),
                    border: active
                        ? null
                        : Border.all(color: DustColors.borderSoft),
                  ),
                  child: Text(genre,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w400,
                        color: active
                            ? DustColors.textOnBrand
                            : DustColors.textPrimary,
                      )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DustSpacing.lg * 1.5),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: DustColors.brandPrimary,
                foregroundColor: DustColors.textOnBrand,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DustRadius.full)),
              ),
              child: Text(_submitting ? '저장 중...' : 'DUST-ART 시작하기',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint,
      {bool number = false}) {
    return TextField(
      controller: controller,
      keyboardType: number ? TextInputType.number : null,
      inputFormatters:
          number ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: const TextStyle(fontSize: 14, color: DustColors.textPrimary),
      decoration: _decoration(hint: hint),
    );
  }

  InputDecoration _decoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(fontSize: 13, color: DustColors.textSecondary),
      filled: true,
      fillColor: DustColors.bgSurface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DustRadius.sm),
        borderSide: const BorderSide(color: DustColors.borderSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DustRadius.sm),
        borderSide: const BorderSide(color: DustColors.borderSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DustRadius.sm),
        borderSide: const BorderSide(color: DustColors.brandPrimary),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DustSpacing.xs),
      child: Text(text,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: DustColors.textPrimary)),
    );
  }
}
