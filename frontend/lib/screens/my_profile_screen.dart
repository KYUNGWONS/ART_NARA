import 'package:flutter/material.dart';

import '../constants/art_tokens.dart';
import '../models/user_profile_response.dart';
import '../services/user_api_service.dart';
import 'certificate_screen.dart';
import 'liked_artworks_screen.dart';
import 'order_history_screen.dart';

/// 내 프로필 조회 화면 (GET /users/me)
class MyProfileScreen extends StatefulWidget {
  /// 마이페이지 탭 안에서 쓸 때는 MainScreen 이 헤더를 그리므로 AppBar 를 숨긴다.
  final bool embedded;

  const MyProfileScreen({super.key, this.embedded = false});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  UserProfileData? _profile;
  bool _loading = true;
  bool _switching = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final response = await UserApiService.getMe();
    if (!mounted) return;
    setState(() {
      _profile = response?.data;
      _loading = false;
    });
  }

  /// 백엔드 userType(KOREAN_STUDENT/FOREIGN_TOURIST) → 서비스 용어(작가/컬렉터)
  String _roleLabel(String userType) =>
      userType.toUpperCase().startsWith('FOREIGN') ? '컬렉터' : '작가';

  /// 역할 전환 확인 후 서버에 반영한다. 등록한 작품·구매 내역은 그대로 남는다.
  Future<void> _confirmRoleChange(UserProfileData p) async {
    final isArtist = !p.userType!.toUpperCase().startsWith('FOREIGN');
    final nextType = isArtist ? 'FOREIGN_TOURIST' : 'KOREAN_STUDENT';
    final nextLabel = isArtist ? '컬렉터' : '작가';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ArtColors.bgSurface,
        title: Text('$nextLabel(으)로 바꿀까요?',
            style: ArtText.body.copyWith(fontWeight: FontWeight.w700)),
        content: Text(
          isArtist
              ? '판매 등록·제안 기능이 숨겨지고 작품 구매 중심으로 바뀝니다. '
                  '등록한 작품과 거래 내역은 그대로 남아요.'
              : '작품을 등록하고 제작 의뢰에 제안할 수 있게 됩니다.',
          style: ArtText.caption,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
                backgroundColor: ArtColors.brandPrimary),
            child: Text('$nextLabel(으)로 변경'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _switching = true);
    final ok = await UserApiService.changeRole(
      nickname: p.nickname,
      interests: p.interests,
      userType: nextType,
    );
    if (!mounted) return;
    setState(() => _switching = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('역할을 바꾸지 못했어요. 잠시 후 다시 시도해주세요')),
      );
      return;
    }
    await _loadProfile();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$nextLabel(으)로 바꿨어요')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArtColors.bgCanvas,
      appBar: widget.embedded
          ? null
          : AppBar(
        backgroundColor: ArtColors.bgCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: ArtColors.textPrimary,
        ),
        title: Text(
          '내 프로필',
          style: ArtText.body.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ArtColors.brandPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: ArtColors.brandPrimary),
            )
          : _profile == null
          ? Center(
              child: Text(
                '프로필을 불러올 수 없어요',
                style: ArtText.body.copyWith(color: ArtColors.textSecondary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(ArtSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(_profile!),
                  const SizedBox(height: ArtSpacing.md),
                  _buildMenuTile(
                    icon: Icons.qr_code_scanner,
                    title: '소유권 인증서 · 디지털 소유권',
                    subtitle: 'QR 스캔으로 소유권 인증서를 확인하세요',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const CertificateScreen()),
                    ),
                  ),
                  const SizedBox(height: ArtSpacing.sm),
                  _buildMenuTile(
                    icon: Icons.favorite_border,
                    title: '관심 작품',
                    subtitle: '하트를 누른 작품을 모아봤어요',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const LikedArtworksScreen()),
                    ),
                  ),
                  const SizedBox(height: ArtSpacing.sm),
                  _buildMenuTile(
                    icon: Icons.receipt_long_outlined,
                    title: '주문 내역',
                    subtitle: '결제한 작품과 소유권 발급 내역을 확인하세요',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const OrderHistoryScreen()),
                    ),
                  ),
                  const SizedBox(height: ArtSpacing.lg),
                  _buildSection('기본 정보', [
                    _row('닉네임', _profile!.nickname),
                    if (_profile!.age != null) _row('나이', '${_profile!.age}세'),
                    if (_profile!.userType != null)
                      _row('역할', _roleLabel(_profile!.userType!)),
                    _row('프로필 완료', _profile!.profileCompleted ? '완료' : '미완료'),
                  ]),
                  if (_profile!.region != null) ...[
                    const SizedBox(height: ArtSpacing.md),
                    _buildSection('활동 지역', [
                      _row('지역', _profile!.region!),
                    ]),
                  ],
                  if (_profile!.interests.isNotEmpty) ...[
                    const SizedBox(height: ArtSpacing.md),
                    _buildSection('관심 장르', [
                      _row('장르', _profile!.interests.join(', ')),
                    ]),
                  ],
                  if (_profile!.bio != null && _profile!.bio!.isNotEmpty) ...[
                    const SizedBox(height: ArtSpacing.md),
                    _buildSection('소개', [_row('소개', _profile!.bio!)]),
                  ],
                  const SizedBox(height: ArtSpacing.lg),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: ArtColors.bgSurface,
      borderRadius: BorderRadius.circular(ArtRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(ArtRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(ArtSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ArtRadius.md),
            border: Border.all(color: ArtColors.borderSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ArtColors.bgInfo,
                  borderRadius: BorderRadius.circular(ArtRadius.sm),
                ),
                child: Icon(icon, size: 20, color: ArtColors.brandPrimary),
              ),
              const SizedBox(width: ArtSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ArtText.body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: ArtText.caption),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ArtColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileData p) {
    return Container(
      padding: const EdgeInsets.all(ArtSpacing.lg),
      decoration: BoxDecoration(
        color: ArtColors.bgSurface,
        borderRadius: BorderRadius.circular(ArtRadius.md),
        border: Border.all(color: ArtColors.borderSoft),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: ArtColors.bgSubtle,
            backgroundImage: p.profileImageUrl != null
                ? NetworkImage(p.profileImageUrl!)
                : null,
            child: p.profileImageUrl == null
                ? Text(
                    p.nickname.isNotEmpty ? p.nickname[0] : '?',
                    style: ArtText.section.copyWith(
                      color: ArtColors.brandPrimary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: ArtSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nickname,
                  style: ArtText.body.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (p.age != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${p.age}세',
                    style: ArtText.body.copyWith(
                      fontSize: 15,
                      color: ArtColors.textSecondary,
                    ),
                  ),
                ],
                if (p.userType != null) ...[
                  const SizedBox(height: ArtSpacing.xs),
                  // 배지를 탭하면 작가↔컬렉터 전환. 가입 후에도 역할을 바꿀 수 있어야 한다.
                  InkWell(
                    borderRadius: BorderRadius.circular(ArtRadius.full),
                    onTap: _switching ? null : () => _confirmRoleChange(p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: ArtSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: ArtColors.brandPrimary,
                        borderRadius: BorderRadius.circular(ArtRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _roleLabel(p.userType!),
                            style: ArtText.caption.copyWith(
                              color: ArtColors.textOnBrand,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.swap_horiz_rounded,
                              size: 14, color: ArtColors.textOnBrand),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(ArtSpacing.md),
      decoration: BoxDecoration(
        color: ArtColors.bgSurface,
        borderRadius: BorderRadius.circular(ArtRadius.md),
        border: Border.all(color: ArtColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ArtText.body.copyWith(
              fontWeight: FontWeight.w700,
              color: ArtColors.brandPrimary,
            ),
          ),
          const SizedBox(height: ArtSpacing.sm),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ArtSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: ArtText.body.copyWith(
                fontSize: 14,
                color: ArtColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: ArtText.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
