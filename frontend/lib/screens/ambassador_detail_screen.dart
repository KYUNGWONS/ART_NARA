import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/ambassador.dart';
import '../providers/locale_provider.dart';

/// 앰배서더 상세 화면.
///
/// 홈 쇼케이스([AmbassadorShowcase])의 원형 프로필을 탭하면 진입한다.
/// 대형 사진 + 프로필(이름/학교) + 구사 언어 칩 + 진행 중인 콘텐츠 목록을 보여준다.
class AmbassadorDetailScreen extends StatelessWidget {
  const AmbassadorDetailScreen({super.key, required this.ambassador});

  final Ambassador ambassador;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildHeader(context, locale),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroImage(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfile(),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.lightGrey, height: 1),
                        const SizedBox(height: 20),
                        _buildLanguages(locale),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.lightGrey, height: 1),
                        const SizedBox(height: 20),
                        _buildContents(locale),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 상단 헤더 (< 뒤로 / 앰배서더) ───
  Widget _buildHeader(BuildContext context, LocaleProvider locale) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: Text(
                  locale.tr(AppStrings.ambassadorBack),
                  style: GoogleFonts.gowunDodum(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            Text(
              locale.tr(AppStrings.ambassadorDetailTitle),
              style: GoogleFonts.gowunDodum(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 대형 프로필 사진 (하단 화이트 페이드) ───
  Widget _buildHeroImage() {
    return SizedBox(
      height: 360,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            ambassador.profileImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: AppColors.offWhite,
              child: const Center(
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 64,
                  color: AppColors.grey,
                ),
              ),
            ),
          ),
          // 본문과 자연스럽게 이어지도록 하단을 흰색으로 페이드
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.white],
                stops: [0.7, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 기수 배지 + 이름 + 학교·학과 ───
  Widget _buildProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ambassador.generationLabel,
          style: GoogleFonts.gowunDodum(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          ambassador.name,
          style: GoogleFonts.gowunDodum(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${ambassador.university} · ${ambassador.major}',
          style: GoogleFonts.gowunDodum(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  // ─── 구사 언어 칩 ───
  Widget _buildLanguages(LocaleProvider locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.tr(AppStrings.spokenLanguagesLabel),
          style: GoogleFonts.gowunDodum(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final lang in ambassador.languages)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Text(
                  AppStrings.languageLabels[lang] ?? '',
                  style: GoogleFonts.gowunDodum(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ─── 진행 중인 콘텐츠 목록 ───
  Widget _buildContents(LocaleProvider locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.tr(AppStrings.ongoingContentLabel),
          style: GoogleFonts.gowunDodum(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
          ),
        ),
        const SizedBox(height: 8),
        for (final content in ambassador.contents)
          _ContentRow(content: content),
      ],
    );
  }
}

/// 콘텐츠 한 줄 (이모지 + 제목 + 설명 + 화살표).
class _ContentRow extends StatelessWidget {
  const _ContentRow({required this.content});

  final AmbassadorContent content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(content.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: GoogleFonts.gowunDodum(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.gowunDodum(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
        ],
      ),
    );
  }
}
