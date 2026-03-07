import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:url_launcher/url_launcher.dart';
=======
import 'package:flutter_application_1/theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
>>>>>>> 77950dbc68b5e6df30508993e5765e53217d32f1

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

<<<<<<< HEAD
  void callNumber(String number) async {
    final Uri url = Uri.parse("tel:$number");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Widget sosButton(String title, IconData icon, Color color, String number) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => callNumber(number),
        child: Container(
          width: 110,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
              )
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
=======
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool backendConnected = false;
  int segmentsCount = 0;
  int safePointsCount = 0;
  String testStatus = "";
  String currentLocation = "Detecting location...";
    bool insightsLoading = false;
  String insightsSummary = "";
  List<String> insightHighlights = [];

 @override
  void initState() {
    super.initState();
    getLocation();
    _runApiTest();
    _loadHomeInsights();
  }
  Future<void> _loadHomeInsights() async {
      setState(() {
        insightsLoading = true;
      });

      const double lat = 28.6139;
      const double lng = 77.2090;

      final data = await ApiClient.getHomeInsights(
        lat: lat,
        lng: lng,
        radiusKm: 1.5,
        hour: DateTime.now().hour,
      );

      setState(() {
        insightsLoading = false;

        if (data != null) {
          insightsSummary = (data["summary"] ?? "").toString();
          insightHighlights = ((data["highlights"] ?? []) as List)
              .map((e) => e.toString())
              .toList();
        } else {
          insightsSummary = "Could not load AI insights right now.";
          insightHighlights = [];
        }
      });
    }
  Future<void> _runApiTest() async {
  setState(() {
    testStatus = "Testing API...";
  });

  // Same demo coords you use in your map (New Delhi)
  const double lat = 28.6139;
  const double lng = 77.2090;

  final segs = await ApiClient.getNearbySegments(
    lat: lat,
    lng: lng,
    radiusKm: 2.0,
    limit: 50,
  );

  final points = await ApiClient.getNearbySafePoints(
    lat: lat,
    lng: lng,
    radiusKm: 2.0,
    limit: 50,
  );

  setState(() {
    segmentsCount = segs.length;
    safePointsCount = points.length;
  });

  if (segs.isNotEmpty) {
    print("First segment JSON: ${segs.first}");
  } else {
    print("No segments returned (seed segments first).");
  }

  if (points.isNotEmpty) {
    print("First safe point JSON: ${points.first}");
  } else {
    print("No safe points returned (insert/seed safe_points).");
  }
}
    Future<void> getLocation() async {
      try {
        setState(() {
          currentLocation = "Checking location services...";
        });

        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          setState(() {
            currentLocation = "Turn on Location Services";
          });
          return;
        }

        setState(() {
          currentLocation = "Checking permission...";
        });

        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied) {
          setState(() {
            currentLocation = "Location permission denied";
          });
          return;
        }

        if (permission == LocationPermission.deniedForever) {
          setState(() {
            currentLocation = "Location permission denied forever";
          });
          return;
        }

        setState(() {
          currentLocation = "Getting coordinates...";
        });

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );

        setState(() {
          currentLocation = "Finding place name...";
        });

        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isEmpty) {
          setState(() {
            currentLocation =
                "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
          });
          return;
        }

        final place = placemarks.first;
        final locality = place.locality?.trim();
        final area = place.subLocality?.trim();
        final state = place.administrativeArea?.trim();

        setState(() {
          currentLocation = [
            if (area != null && area.isNotEmpty) area,
            if (locality != null && locality.isNotEmpty) locality,
            if (state != null && state.isNotEmpty) state,
          ].join(", ");
        });
      } catch (e) {
        setState(() {
          currentLocation = "Location error: $e";
        });
        debugPrint("Location error: $e");
      }
    }

 Widget roundedMap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(28.6139, 77.2090), // New Delhi demo
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

  Widget infoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(title),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xfff4f6f8),

      appBar: AppBar(
        title: const Text("SafeEscape"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
=======
  floatingActionButton: FloatingActionButton.extended(
  backgroundColor: AppTheme.primaryBlue,
  label: const Text("Chat with Scout"),
  icon: const Icon(Icons.smart_toy),

  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: AIAssistant(),
        ),
      ),
    );
  },
),
  body: SingleChildScrollView(
>>>>>>> 77950dbc68b5e6df30508993e5765e53217d32f1
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD

            /// SAFE AREA STATUS
            const Text(
              "Safe Area Status",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
=======
            const GradientHeader(
              title: "SAFESCAPE",
              subtitle: "Emotional Safety Intelligence",
            ),
            _locationBanner(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                testStatus,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 12),
            roundedMap(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.shield, color: Colors.white, size: 35),
                  SizedBox(width: 12),
                  Expanded(
                    child: infoCard(
                      title: "Safe Areas",
                      value: safePointsCount.toString(),
                      subtitle: "from backend",
                      icon: Icons.trending_up,
                      iconColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: infoCard(
                      title: "Alerts",
                      value: "3",
                      subtitle: "nearby cautions",
                      icon: Icons.warning,
                      iconColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}