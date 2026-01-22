import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart'; // Ensure this file exists and contains your Render logic

void main() {
  runApp(const EquipGuardApp());
}

class EquipGuardApp extends StatelessWidget {
  const EquipGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EquipGuard',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 950
        cardColor: const Color(0xFF1E293B), // Slate 800
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 1. STATE VARIABLES
  String status = "Waiting...";
  double temperature = 0.0;
  double vibration = 0.0;
  bool isAnomaly = false;

  Timer? _timer;
  bool isAlertVisible =
      false; // Prevents multiple popups stacking on top of each other

  @override
  void initState() {
    super.initState();
    // Start polling data every 2 seconds
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) => _fetchData(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 2. LOGIC ENGINE
  Future<void> _fetchData() async {
    // A. Simulate Sensors (Local simulation)
    final random = Random();
    double simTemp = 50 + random.nextDouble() * 20; // Normal: 50-70 C
    double simVib = 10 + random.nextDouble() * 5; // Normal: 10-15 Hz
    double simVolt = 220 + random.nextDouble() * 2; // Normal: 220V

    // B. FAILURE TRIGGER (Every 10 seconds)
    // Forces a high temp to test the Critical Alert
    if (DateTime.now().second % 10 < 2) {
      simTemp = 95.0;
    }

    // C. Get Prediction from Cloud
    final result = await ApiService.getPrediction(simTemp, simVib, simVolt);

    // D. Update UI
    if (result.isNotEmpty && mounted) {
      setState(() {
        temperature = simTemp;
        vibration = simVib;
        status = result['prediction']['status'];
        isAnomaly = result['prediction']['is_anomaly'];
      });

      // E. TRIGGER ALERT POPUP (Sprint 15)
      if (status == "Critical" && !isAlertVisible) {
        _showCriticalDialog();
      }
    }
  }

  void _showCriticalDialog() {
    isAlertVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false, // User MUST tap button to close
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[900],
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "CRITICAL ALERT",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          "Machine temperature has exceeded safe limits (95°C). Immediate maintenance required.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              isAlertVisible =
                  false; // Allow alert to show again if condition persists
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              "ACKNOWLEDGE",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Colors
    Color statusColor = Colors.greenAccent;
    if (status == "Warning") statusColor = Colors.orangeAccent;
    if (status == "Critical") statusColor = Colors.redAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "EquipGuard Mobile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              "System Status",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 5),

            // MAIN STATUS CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    status == "Critical"
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    color: statusColor,
                    size: 64,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isAnomaly ? "⚠️ Anomaly Detected" : "Operating Normally",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // METRICS GRID
            const Text(
              "Live Telemetry",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: "Temp",
                    value: "${temperature.toStringAsFixed(1)}°C",
                    icon: Icons.thermostat,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _MetricCard(
                    title: "Vibration",
                    value: "${vibration.toStringAsFixed(1)} Hz",
                    icon: Icons.speed,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
