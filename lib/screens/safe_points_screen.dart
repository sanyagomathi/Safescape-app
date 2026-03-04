import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/gradient_header.dart';
import '../theme.dart';
import '../api/api_client.dart';

class SafePointsScreen extends StatefulWidget {
  const SafePointsScreen({super.key});

  @override
  State<SafePointsScreen> createState() => _SafePointsScreenState();
}

class _SafePointsScreenState extends State<SafePointsScreen> {
  bool loading = false;
  String error = "";

  List<dynamic> allPoints = [];
  List<dynamic> visiblePoints = [];

  String? selectedCategory; // null = all

  Future<void> _loadSafePoints() async {
  setState(() {
    loading = true;
    error = "";
  });

  try {
    // Using same demo location as your map for now (New Delhi)
    const lat = 28.6139;
    const lng = 77.2090;

    final points = await ApiClient.getNearbySafePoints(
      lat: lat,
      lng: lng,
      radiusKm: 3.0,
      category: selectedCategory, // null => all
      limit: 200,
    );

    setState(() {
      allPoints = points;
      visiblePoints = points;
      loading = false;
    });
  } catch (e) {
    setState(() {
      loading = false;
      error = "Failed to load safe points";
    });
  }
}
  int selected = 0;
final categories = const [
  "All",
  "police",
  "medical",
  "transit",
  "commercial",
];
@override
void initState() {
  super.initState();
  _loadSafePoints();
}

 Widget _chip(String text, bool active) {
  return Padding(
    padding: const EdgeInsets.only(right: 10),
    child: ChoiceChip(
      label: Text(text),
      selected: active,
      onSelected: (_) async {
        setState(() {
          selectedCategory = (text == "All") ? null : text;
        });
        await _loadSafePoints();
      },
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

  Widget _safePointCard(dynamic p) {
    final name = (p["name"] ?? "Unknown").toString();
    final category = (p["category"] ?? "").toString();
    final phone = (p["phone"] ?? "").toString();
    final is24 = (p["is_24x7"] == true);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
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
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              if (is24)
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
          const SizedBox(height: 8),
          Text(category, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.call_outlined, size: 18, color: Colors.black54),
              const SizedBox(width: 6),
              Text(phone.isEmpty ? "N/A" : phone),
            ],
          ),
        ],
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final countText = loading ? "Loading..." : "${visiblePoints.length} found";

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
              children: categories.map((cat) {
                final active =
                    (cat == "All" && selectedCategory == null) ||
                    (cat == selectedCategory);

                return _chip(cat, active);
              }).toList(),
            ),
             ),

          const SizedBox(height: 14),

          // List header
          // List header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  "Nearby Safe Points",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  countText,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                    ? Center(child: Text(error))
                    : visiblePoints.isEmpty
                        ? const Center(child: Text("No safe points found."))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: visiblePoints.length,
                            itemBuilder: (context, i) => _safePointCard(visiblePoints[i]),
                          ),
          ),
        ],
      ),
    );
  }
}