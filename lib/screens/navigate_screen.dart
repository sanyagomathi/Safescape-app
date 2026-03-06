import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../api/api_client.dart';
import '../widgets/gradient_header.dart';
import '../theme.dart';

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  final MapController mapController = MapController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  List<Polyline> routeLines = [];
  bool loadingRoutes = false;
  bool fittedOnce = false;

  @override
  void initState() {
    super.initState();

    // 1) Guaranteed visible test polyline
    routeLines = [
      Polyline(
        points: const [
          LatLng(19.0760, 72.8777),
          LatLng(19.0820, 72.8850),
        ],
        strokeWidth: 12,
        color: Colors.blue,
      ),
    ];

    // 2) Load real routes only after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSafetyRoutes();
    });
  }

  Future<List<LatLng>> getRoadRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    final url =
        "https://router.project-osrm.org/route/v1/foot/$startLng,$startLat;$endLng,$endLat?overview=full&geometries=geojson";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body);
    final coords = data["routes"][0]["geometry"]["coordinates"] as List;

    return coords
        .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
        .toList();
  }

  Future<void> loadSafetyRoutes() async {
    if (loadingRoutes) return;
    loadingRoutes = true;

    const lat = 19.0760;
    const lng = 72.8777;

    final segments = await ApiClient.getNearbySegments(
      lat: lat,
      lng: lng,
      radiusKm: 1.5,
      limit: 20,
    );

    print("Segments received: ${segments.length}");

    final List<Polyline> lines = [];

    for (final seg in segments) {
      final segLat = (seg["lat"] as num).toDouble();
      final segLng = (seg["lng"] as num).toDouble();

      final routePoints = await getRoadRoute(
        segLat,
        segLng,
        segLat + 0.002,
        segLng + 0.002,
      );

      print("Route points: ${routePoints.length}");

      if (routePoints.isEmpty) continue;

      lines.add(
        Polyline(
          points: routePoints,
          strokeWidth: 10,
          color: Colors.red,
        ),
      );
    }

    print("Total polylines: ${lines.length}");

    if (!mounted) return;

    setState(() {
      routeLines = lines.isNotEmpty
          ? lines
          : [
              Polyline(
                points: const [
                  LatLng(19.0760, 72.8777),
                  LatLng(19.0820, 72.8850),
                ],
                strokeWidth: 12,
                color: Colors.blue,
              ),
            ];
    });

    if (!fittedOnce && routeLines.isNotEmpty) {
      fittedOnce = true;

      final allPoints = <LatLng>[];
      for (final line in routeLines) {
        allPoints.addAll(line.points);
      }

      if (allPoints.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(allPoints);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(30),
            ),
          );
        });
      }
    }

    loadingRoutes = false;
  }


  Future<LatLng?> geocodePlace(String query) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "User-Agent": "com.example.safescape",
      },
    );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as List;
      if (data.isEmpty) return null;

      final lat = double.parse(data[0]["lat"]);
      final lon = double.parse(data[0]["lon"]);

      return LatLng(lat, lon);
  }
      Future<void> generateRealRoute() async {
        final fromText = fromController.text.trim();
        final toText = toController.text.trim();

        if (fromText.isEmpty || toText.isEmpty) return;

        final fromLatLng = await geocodePlace(fromText);
        final toLatLng = await geocodePlace(toText);

        if (fromLatLng == null || toLatLng == null) {
          print("Could not find one or both locations");
          return;
        }

        final routePoints = await getRoadRoute(
          fromLatLng.latitude,
          fromLatLng.longitude,
          toLatLng.latitude,
          toLatLng.longitude,
        );

        if (routePoints.isEmpty) {
          print("No route found");
          return;
        }

        setState(() {
          routeLines = [
            Polyline(
              points: routePoints,
              strokeWidth: 12,
              color: Colors.blue,
            ),
          ];
        });

        final bounds = LatLngBounds.fromPoints(routePoints);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(30),
            ),
          );
        });
      }

 Widget _locationField({
  required TextEditingController controller,
  required IconData icon,
  required String hint,
}) {
  return Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    ),
  );
}
 
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: Column(
        children: [
          const GradientHeader(
            title: "Safe Navigation",
            subtitle: "Find the safest route to your destination",
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                children: [
                  _locationField(
                  controller: fromController,
                  icon: Icons.location_on_outlined,
                  hint: "Your location",
                ),
                const SizedBox(height: 14),
                _locationField(
                  controller: toController,
                  icon: Icons.send_outlined,
                  hint: "Where to?",
                ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: generateRealRoute,
                      child: const Text(
                        "Find Safe Routes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.04),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: FlutterMap(
                          mapController: mapController,
                          options: const MapOptions(
                            initialCenter: LatLng(19.0760, 72.8777),
                            initialZoom: 14,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                              userAgentPackageName: "com.example.safescape",
                            ),
                            PolylineLayer(
                              polylines: routeLines,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}