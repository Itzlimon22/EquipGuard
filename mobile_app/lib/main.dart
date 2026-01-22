import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  // Placeholder data for now (Sprint 13)
  String status = "Healthy";
  double temperature = 55.0;
  bool isAnomaly = false;

  @override
  Widget build(BuildContext context) {
    // Determine color based on status
    Color statusColor = status == "Critical" ? Colors.redAccent : Colors.greenAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text("EquipGuard Mobile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER GREETING
            const Text("System Status", style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 5),
            
            // 2. MAIN STATUS CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    status == "Critical" ? Icons.warning_amber_rounded : Icons.check_circle_outline,
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
                    isAnomaly ? "Anomaly Detected" : "Operating Normally",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // 3. LIVE METRICS GRID
            const Text("Live Telemetry", style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                    value: "12 Hz",
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

// Helper Widget for small cards
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

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
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}