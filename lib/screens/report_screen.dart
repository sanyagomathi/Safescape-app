import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/report_tile.dart';
import '../api/api_client.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool submitting = false;
  String status = "";

  // For now we use the same demo location as your map.
  // Later we will use real GPS.
  static const double demoLat = 28.6139;
  static const double demoLng = 77.2090;

  Future<String?> _getAnyNearbySegmentId() async {
    final segs = await ApiClient.getNearbySegments(
      lat: demoLat,
      lng: demoLng,
      radiusKm: 2.0,
      limit: 1,
    );
    if (segs.isEmpty) return null;
    return segs.first["id"].toString();
  }

  Future<void> _submit(String category) async {
    if (submitting) return;

    setState(() {
      submitting = true;
      status = "Submitting...";
    });

    try {
      final segmentId = await _getAnyNearbySegmentId();

      if (segmentId == null) {
        setState(() {
          submitting = false;
          status = "No segments found. Seed segments first.";
        });
        return;
      }

      final hour = DateTime.now().hour;

      final ok = await ApiClient.submitReview(
        segmentId: segmentId,
        category: category,
        gender: "woman",
        hour: hour,
        rating: 0.2,
        note: "Report from app",
      );

      if (!ok) {
        setState(() {
          submitting = false;
          status = "Submit failed ❌";
        });
        return;
      }

      // NEW: fetch score
      final score = await ApiClient.getSegmentScore(segmentId, hour);

      print("DEBUG segmentId=$segmentId hour=$hour");
      print("DEBUG score response: $score");

      final overall = score?["overall"]?.toString() ?? "???";

      setState(() {
        submitting = false;
        status = "Submitted ✅ Score now: $overall";
      });
    } catch (e) {
      print("Submit error: $e");
      setState(() {
        submitting = false;
        status = "Error submitting ❌";
      });
    }
  }
  Widget _locationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on_outlined, color: Colors.black54),
              SizedBox(width: 8),
              Text(
                "Current Location",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "MG Road, Near Central Metro Station",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "Change Location",
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w700,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GradientHeader(
              title: "Report Safety Concerns",
              subtitle: "Help build a safer community",
            ),
            const SizedBox(height: 18),
            _locationCard(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "What would you like to report?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.15,
                children: [
                  ReportTile(
                    icon: Icons.lightbulb_outline,
                    iconColor: Colors.orange,
                    label: "Poor Lighting",
                    onTap: submitting ? null : () => _submit("poor_lighting"),
                  ),
                  ReportTile(
                    icon: Icons.report_gmailerrorred,
                    iconColor: Colors.red,
                    label: "Harassment",
                    onTap: submitting ? null : () => _submit("harassment"),
                  ),
                  ReportTile(
                    icon: Icons.place_outlined,
                    iconColor: Colors.deepOrange,
                    label: "Isolated Area",
                    onTap: submitting ? null : () => _submit("isolated_area"),
                  ),
                  ReportTile(
                    icon: Icons.people_outline,
                    iconColor: Colors.blue,
                    label: "Crowded/Safe",
                    onTap: submitting ? null : () => _submit("crowded_safe"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (submitting) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  if (submitting) const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      status,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}