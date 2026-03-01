import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/gradient_header.dart';
import '../theme.dart';

class SafePointsScreen extends StatefulWidget {
  const SafePointsScreen({super.key});

  @override
  State<SafePointsScreen> createState() => _SafePointsScreenState();
}

class _SafePointsScreenState extends State<SafePointsScreen> {
  int selected = 0;
  final categories = const ["All (4)", "Police (1)", "Medical (1)", "Transit (1)", "Commercial (1)"];

  Widget _chip(String text, bool active) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(text),
        selected: active,
        onSelected: (_) {},
        selectedColor: AppTheme.primaryBlue,
        labelStyle: TextStyle(
          color: active ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _roundedMap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(28.6139, 77.2090),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.safescape',
          ),
        ],
      ),
    );
  }

  Widget _safePointCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shield_outlined, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Central Police Station",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "24/7",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          const Text("Police Station", style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 14),
          Row(
            children: const [
              Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
              SizedBox(width: 6),
              Text("0.8 km"),
              SizedBox(width: 18),
              Icon(Icons.call_outlined, size: 18, color: Colors.black54),
              SizedBox(width: 6),
              Text("100"),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.send),
                  label: const Text("Navigate"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.call),
                  label: const Text("Call"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GradientHeader(
            title: "Safe Points",
            subtitle: "Find safe locations nearby",
          ),
          const SizedBox(height: 18),
          _roundedMap(),
          const SizedBox(height: 14),

          // Chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(categories.length, (i) {
                final active = i == selected;
                return GestureDetector(
                  onTap: () => setState(() => selected = i),
                  child: _chip(categories[i], active),
                );
              }),
            ),
          ),

          const SizedBox(height: 14),

          // List header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: const [
                Text(
                  "Nearby Safe Points",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text("4 found", style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _safePointCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}