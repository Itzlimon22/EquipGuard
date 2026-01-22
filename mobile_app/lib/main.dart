import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart'; // <--- Links to your Render Backend

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
  String status = "Waiting..."; // Initial state before data arrives
  double temperature = 0.0;
  double vibration = 0.0;
  bool isAnomaly = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 2. START POLLING: Fetch data every 2 seconds
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) => _fetchData(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Good practice: Stop timer when screen closes
    super.dispose();
  }

  // 3. THE LOGIC ENGINE
  Future<void> _fetchData() async {
    // A. Simulate Sensor Readings (Since phone has no industrial sensors)
    final random = Random();
    double simTemp = 50 + random.nextDouble() * 20; // Normal: 50-70 C
    double simVib = 10 + random.nextDouble() * 5; // Normal: 10-15 Hz
    double simVolt = 220 + random.nextDouble() * 2; // Normal: 220V

    // B. FAILURE SIMULATION TRIGGER
    // Every 10 seconds (when seconds end in 0 or 1), force a "Critical" reading
    // so you can see the Red Alert screen.
    if (DateTime.now().second % 10 < 2) {
      simTemp = 95.0; // Overheating!
    }

    // C. Send data to Render API & Get Prediction
    final result = await ApiService.getPrediction(simTemp, simVib, simVolt);

    // D. Update the UI
    if (result.isNotEmpty && mounted) {
      setState(() {
        temperature = simTemp;
        vibration = simVib;
        // Parse the nested JSON from Python
        status = result['prediction']['status'];
        isAnomaly = result['prediction']['is_anomaly'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4. DYNAMIC UI COLORS based on Status
    Color statusColor = Colors.greenAccent; // Default Healthy
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
            // HEADER
            const Text(
              "System Status",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 5),

            // MAIN STATUS CARD (Updates dynamically)
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

            // LIVE METRICS GRID
            const Text(
              "Live Telemetry",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                // Temperature Card
                Expanded(
                  child: _MetricCard(
                    title: "Temp",
                    value: "${temperature.toStringAsFixed(1)}°C",
                    icon: Icons.thermostat,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 15),
                // Vibration Card
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

// Helper Widget for consistent card design
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
