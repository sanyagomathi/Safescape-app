import 'package:flutter/material.dart';

class AppTheme {
  static const primaryBlue = Color.fromARGB(255, 60, 184, 238);
  static const primaryBlueDark = Color.fromARGB(255, 68, 118, 217);
  static const lightGrey = Color(0xFFF4F4F6);

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: lightGrey,
    colorScheme: ColorScheme.fromSeed(seedColor:primaryBlue),
  );
}