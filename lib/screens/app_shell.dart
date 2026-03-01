import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'navigate_screen.dart';
import 'report_screen.dart';
import 'safe_points_screen.dart';
import 'profile_screen.dart';

import '../widgets/bottom_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    NavigateScreen(),
    ReportScreen(),
    SafePointsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: SafeBottomNav(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
      ),
    );
  }
}