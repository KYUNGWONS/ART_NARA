import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.black,
        ),
        title: Text(
          '내 프로필',
          style: GoogleFonts.gowunDodum(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _profile == null
          ? Center(
              child: Text(
                '프로필을 불러올 수 없어요',
                style: GoogleFonts.gowunDodum(
                  fontSize: 16,
                  color: AppColors.grey,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(_profile!),
                  const SizedBox(height: 16),
                  _buildMenuTile(
                    icon: Icons.qr_code_scanner,
                    title: '정품 인증 · 디지털 소유권',
                    subtitle: 'QR 스캔으로 정품 인증서를 확인하세요',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const CertificateScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(
                    icon: Icons.receipt_long_outlined,
                    title: '주문 내역',
                    subtitle: '결제한 작품과 소유권 발급 내역을 확인하세요',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const OrderHistoryScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection('기본 정보', [
                    _row('닉네임', _profile!.nickname),
                    if (_profile!.age != null) _row('나이', '${_profile!.age}세'),
                    if (_profile!.userType != null)
                      _row('역할', _profile!.userType!.toUpperCase().startsWith('FOREIGN') ? '컬렉터' : '작가'),
                    _row('프로필 완료', _profile!.profileCompleted ? '완료' : '미완료'),
                  ]),
                  if (_profile!.address != null ||
                      _profile!.addressDetail != null) ...[
                    const SizedBox(height: 16),
                    _buildSection('주소', [
                      if (_profile!.address != null)
                        _row('주소', _profile!.address!),
                      if (_profile!.addressDetail != null)
                        _row('상세주소', _profile!.addressDetail!),
                    ]),
                  ],
                                                      if (_profile!.interests.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSection('관심 장르', [
                      _row('장르', _profile!.interests.join(', ')),
                    ]),
                  ],
                                    if (_profile!.bio != null && _profile!.bio!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSection('자기소개', [_row('소개', _profile!.bio!)]),
                  ],
                  const SizedBox(height: 24),
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
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileData p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            backgroundImage: p.profileImageUrl != null
                ? NetworkImage(p.profileImageUrl!)
                : null,
            child: p.profileImageUrl == null
                ? Text(
                    p.nickname.isNotEmpty ? p.nickname[0] : '?',
                    style: GoogleFonts.gowunDodum(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nickname,
                  style: GoogleFonts.gowunDodum(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                if (p.age != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${p.age}세',
                    style: GoogleFonts.gowunDodum(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
                if (p.userType != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    p.userType!,
                    style: GoogleFonts.gowunDodum(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.gowunDodum(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.gowunDodum(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.gowunDodum(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
