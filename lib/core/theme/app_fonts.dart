import 'package:flutter/material.dart';

class AppFonts {
  AppFonts._();

  // Use system default (San Francisco on iOS, Roboto on Android)
  // To use custom fonts, set these to the font family name and add to pubspec.yaml
  static const String? display = null; // null = system default
  static const String? text = null;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}
