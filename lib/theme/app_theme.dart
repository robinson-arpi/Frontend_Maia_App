import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color strongColorA = Color(0xFF001781);
  static const Color strongColorB = Color(0xFFD2070F);
  static const Color softColorA = Color(0xFFE7EDF7);
  static const Color softColorB = Color(0xFFFFFFFF);

  // Text Themes
  static const TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(
        fontFamily: 'arialnarrow',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: strongColorA),
    headlineMedium: TextStyle(
        fontFamily: 'arialnarrow', fontSize: 20, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(
        fontFamily: 'arialnarrow', fontSize: 16, fontWeight: FontWeight.normal),
    bodyLarge: TextStyle(fontFamily: 'arialnarrow', fontSize: 16),
    bodyMedium: TextStyle(fontFamily: 'arialnarrow', fontSize: 14),
  );
}
