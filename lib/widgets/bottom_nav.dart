import 'package:flutter/material.dart';

class SafeBottomNav extends StatefulWidget {
  const SafeBottomNav({super.key});

  @override
  State<SafeBottomNav> createState() => _SafeBottomNavState();
}

class _SafeBottomNavState extends State<SafeBottomNav> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) => setState(() => index = i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: "Home",
        ),
        NavigationDestination(
          icon: Icon(Icons.navigation_outlined),
          selectedIcon: Icon(Icons.navigation),
          label: "Navigate",
        ),
        NavigationDestination(
          icon: Icon(Icons.report_outlined),
          selectedIcon: Icon(Icons.report),
          label: "Report",
        ),
        NavigationDestination(
          icon: Icon(Icons.location_on_outlined),
          selectedIcon: Icon(Icons.location_on),
          label: "Safe Points",
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}