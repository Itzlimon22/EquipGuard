import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 1. YOUR RENDER URL
  // We use the live cloud URL so it works on any phone/emulator
  static const String baseUrl = "https://equipguard.onrender.com";

  static Future<Map<String, dynamic>> getPrediction(
    double temp,
    double vib,
    double volt,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/predict");

      // 2. Prepare the JSON data
      final Map<String, dynamic> requestData = {
        "Temperature": temp,
        "Vibration": vib,
        "Voltage": volt,
      };

      // 3. Send POST request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      // 4. Check for success
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Server Error: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      print("Connection Error: $e");
      return {};
    }
  }
}
