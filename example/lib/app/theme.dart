import 'package:flutter/material.dart';

import 'palette.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      surface: AppPalette.surface,
    ),
    scaffoldBackgroundColor: AppPalette.surface,
    cardTheme: CardThemeData(
      color: AppPalette.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppPalette.primary,
      foregroundColor: Colors.white,
    ),
  );
}
