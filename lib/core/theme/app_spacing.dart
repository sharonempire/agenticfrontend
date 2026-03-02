import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  static const double sectionGap = 28.0;
  static const double cardGap = 16.0;
  static const double listItemGap = 12.0;
}

class AppRadius {
  AppRadius._();

  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(20));
  static const BorderRadius full = BorderRadius.all(Radius.circular(999));
  static const BorderRadius sheetTop = BorderRadius.vertical(top: Radius.circular(20));
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 1, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> bottomBar = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, -4)),
  ];
}
