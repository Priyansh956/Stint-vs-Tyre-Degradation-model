import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stint_analysis.dart';

class AnalysisService {
  static String baseUrl = "http://192.168.1.43:8000"; // ← your PC's LAN IP

  static Future<Map<int, StintAnalysis>> analyzeRace({
    required int year,
    required String race,
    required String driver,
  }) async {
    final uri = Uri.parse("$baseUrl/analyze").replace(
      queryParameters: {
        "year": year.toString(),
        "race": race,
        "driver": driver,
      },
    );

    final response = await http.get(uri).timeout(
      const Duration(seconds: 120), // FastF1 is slow on first load
      onTimeout: () => throw Exception(
          "Request timed out. FastF1 may still be loading data — try again."),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body["detail"] ?? "Analysis failed: ${response.statusCode}");
    }

    final body = jsonDecode(response.body);
    final results = body["results"] as Map<String, dynamic>;

    return results.map(
      (key, value) =>
          MapEntry(int.parse(key), StintAnalysis.fromJson(value)),
    );
  }
}