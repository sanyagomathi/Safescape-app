import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/app_shell.dart';

void main() {
  runApp(const SafescapeApp());
}

class SafescapeApp extends StatelessWidget {
  const SafescapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Safescape",
      theme: AppTheme.theme,
      home: AppShell(),
    );
  }
}