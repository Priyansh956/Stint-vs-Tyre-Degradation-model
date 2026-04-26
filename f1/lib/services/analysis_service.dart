import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stint_analysis.dart';

class AnalysisService {
  static String baseUrl = "http://10.0.2.2:8000";

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

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Analysis failed: ${response.statusCode}");
    }

    final body = jsonDecode(response.body);
    final results = body["results"] as Map<String, dynamic>;

    return results.map(
      (key, value) =>
          MapEntry(int.parse(key), StintAnalysis.fromJson(value)),
    );
  }
}
