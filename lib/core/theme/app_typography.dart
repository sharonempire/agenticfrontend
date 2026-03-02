import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle largeTitle = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 34, fontWeight: FontWeight.w700,
    letterSpacing: 0.37, height: 1.21,
    color: AppColors.textPrimary,
  );

  static TextStyle title1 = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 28, fontWeight: FontWeight.w700,
    letterSpacing: 0.36, height: 1.21,
    color: AppColors.textPrimary,
  );

  static TextStyle title2 = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 22, fontWeight: FontWeight.w700,
    letterSpacing: 0.35, height: 1.27,
    color: AppColors.textPrimary,
  );

  static TextStyle title3 = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 20, fontWeight: FontWeight.w600,
    letterSpacing: 0.38, height: 1.25,
    color: AppColors.textPrimary,
  );

  static TextStyle headline = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 17, fontWeight: FontWeight.w600,
    letterSpacing: -0.41, height: 1.29,
    color: AppColors.textPrimary,
  );

  static TextStyle body = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 17, fontWeight: FontWeight.w400,
    letterSpacing: -0.41, height: 1.29,
    color: AppColors.textPrimary,
  );

  static TextStyle callout = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 16, fontWeight: FontWeight.w400,
    letterSpacing: -0.32, height: 1.31,
    color: AppColors.textPrimary,
  );

  static TextStyle subheadline = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 15, fontWeight: FontWeight.w400,
    letterSpacing: -0.24, height: 1.33,
    color: AppColors.textPrimary,
  );

  static TextStyle footnote = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 13, fontWeight: FontWeight.w400,
    letterSpacing: -0.08, height: 1.38,
    color: AppColors.textSecondary,
  );

  static TextStyle caption1 = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.33,
    color: AppColors.textSecondary,
  );

  static TextStyle caption2 = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 11, fontWeight: FontWeight.w400,
    letterSpacing: 0.07, height: 1.27,
    color: AppColors.textTertiary,
  );

  static TextStyle buttonLarge = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 17, fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
  );

  static TextStyle buttonSmall = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 13, fontWeight: FontWeight.w600,
    letterSpacing: -0.08,
  );
}
