import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';
import '../models/user_profile_response.dart';
import '../services/user_api_service.dart';
import 'certificate_screen.dart';
import 'order_history_screen.dart';

/// 내 프로필 조회 화면 (GET /users/me)
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  UserProfileData? _profile;
  bool _loading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DustColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: DustColors.bgCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: DustColors.textPrimary,
        ),
        title: Text(
          '내 프로필',
          style: DustText.body.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: DustColors.brandPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: DustColors.brandPrimary),
            )
          : _profile == null
          ? Center(
              child: Text(
                '프로필을 불러올 수 없어요',
                style: DustText.body.copyWith(color: DustColors.textSecondary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DustSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(_profile!),
                  const SizedBox(height: DustSpacing.md),
                  _buildMenuTile(
                    icon: Icons.qr_code_scanner,
                    title: '정품 인증 · 디지털 소유권',
                    subtitle: 'QR 스캔으로 정품 인증서를 확인하세요',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const CertificateScreen()),
                    ),
                  ),
                  const SizedBox(height: DustSpacing.sm),
                  _buildMenuTile(
                    icon: Icons.receipt_long_outlined,
                    title: '주문 내역',
                    subtitle: '결제한 작품과 소유권 발급 내역을 확인하세요',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const OrderHistoryScreen()),
                    ),
                  ),
                  const SizedBox(height: DustSpacing.lg),
                  _buildSection('기본 정보', [
                    _row('닉네임', _profile!.nickname),
                    if (_profile!.age != null) _row('나이', '${_profile!.age}세'),
                    if (_profile!.userType != null)
                      _row('역할', _roleLabel(_profile!.userType!)),
                    _row('프로필 완료', _profile!.profileCompleted ? '완료' : '미완료'),
                  ]),
                  if (_profile!.address != null ||
                      _profile!.addressDetail != null) ...[
                    const SizedBox(height: DustSpacing.md),
                    _buildSection('활동 지역', [
                      if (_profile!.address != null)
                        _row('지역', _profile!.address!),
                      if (_profile!.addressDetail != null)
                        _row('상세', _profile!.addressDetail!),
                    ]),
                  ],
                  if (_profile!.interests.isNotEmpty) ...[
                    const SizedBox(height: DustSpacing.md),
                    _buildSection('관심 장르', [
                      _row('장르', _profile!.interests.join(', ')),
                    ]),
                  ],
                  if (_profile!.bio != null && _profile!.bio!.isNotEmpty) ...[
                    const SizedBox(height: DustSpacing.md),
                    _buildSection('소개', [_row('소개', _profile!.bio!)]),
                  ],
                  const SizedBox(height: DustSpacing.lg),
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
      color: DustColors.bgSurface,
      borderRadius: BorderRadius.circular(DustRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(DustRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(DustSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DustRadius.md),
            border: Border.all(color: DustColors.borderSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DustColors.bgInfo,
                  borderRadius: BorderRadius.circular(DustRadius.sm),
                ),
                child: Icon(icon, size: 20, color: DustColors.brandPrimary),
              ),
              const SizedBox(width: DustSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: DustText.body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: DustText.caption),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: DustColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileData p) {
    return Container(
      padding: const EdgeInsets.all(DustSpacing.lg),
      decoration: BoxDecoration(
        color: DustColors.bgSurface,
        borderRadius: BorderRadius.circular(DustRadius.md),
        border: Border.all(color: DustColors.borderSoft),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: DustColors.bgSubtle,
            backgroundImage: p.profileImageUrl != null
                ? NetworkImage(p.profileImageUrl!)
                : null,
            child: p.profileImageUrl == null
                ? Text(
                    p.nickname.isNotEmpty ? p.nickname[0] : '?',
                    style: DustText.section.copyWith(
                      color: DustColors.brandPrimary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: DustSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nickname,
                  style: DustText.body.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (p.age != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${p.age}세',
                    style: DustText.body.copyWith(
                      fontSize: 15,
                      color: DustColors.textSecondary,
                    ),
                  ),
                ],
                if (p.userType != null) ...[
                  const SizedBox(height: DustSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DustSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: DustColors.brandPrimary,
                      borderRadius: BorderRadius.circular(DustRadius.full),
                    ),
                    child: Text(
                      _roleLabel(p.userType!),
                      style: DustText.caption.copyWith(
                        color: DustColors.textOnBrand,
                        fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(DustSpacing.md),
      decoration: BoxDecoration(
        color: DustColors.bgSurface,
        borderRadius: BorderRadius.circular(DustRadius.md),
        border: Border.all(color: DustColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DustText.body.copyWith(
              fontWeight: FontWeight.w700,
              color: DustColors.brandPrimary,
            ),
          ),
          const SizedBox(height: DustSpacing.sm),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DustSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: DustText.body.copyWith(
                fontSize: 14,
                color: DustColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: DustText.body.copyWith(
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
