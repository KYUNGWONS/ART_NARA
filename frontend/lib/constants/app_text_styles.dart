import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 대학생 타겟 친근한 폰트 체계
/// - 제목/강조: Jua (둥글고 친근한 느낌)
/// - 본문: Gowun Dodum (부드럽고 읽기 좋은 산세리프)
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading1 => GoogleFonts.jua(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static TextStyle get heading2 => GoogleFonts.jua(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static TextStyle get heading3 => GoogleFonts.jua(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static TextStyle get subtitle => GoogleFonts.gowunDodum(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.darkGrey,
  );

  static TextStyle get body => GoogleFonts.gowunDodum(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.darkGrey,
  );

  static TextStyle get bodyLight => GoogleFonts.gowunDodum(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );

  static TextStyle get button => GoogleFonts.jua(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  static TextStyle get caption => GoogleFonts.gowunDodum(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );
}
