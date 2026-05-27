import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData buildRouteFitTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: RouteFitColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: RouteFitColors.primary,
      primary: RouteFitColors.primary,
      secondary: RouteFitColors.accent,
      surface: Colors.white,
    ),
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(fontWeight: FontWeight.w800),
      titleLarge: TextStyle(fontWeight: FontWeight.w800),
      titleMedium: TextStyle(fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(fontWeight: FontWeight.w500),
    ),
  );
}
