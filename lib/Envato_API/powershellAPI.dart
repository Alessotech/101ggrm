import 'dart:convert';
import 'package:http/http.dart' as http;

class StocipDownloader {
  static const String baseUrl = 'https://stocip-downloader-production-9e65.up.railway.app';

  static Future<String?> getDownloadUrl(String inputUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/get-download-url'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': inputUrl}),
      );

      print("📡 Response Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['generatedText'] != null) {
          return data['generatedText'];
        }
      }
    } catch (e) {
      print("❌ Error fetching download URL: $e");
    }

    return null;
  }

  static Future<List<Map<String, dynamic>>> batchDownload(List<String> urls) async {
    if (urls.length > 5) {
      throw Exception("Max 5 links allowed.");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/batch-download'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'urls': urls}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['results']);
      }
    }

    return [];
  }

}
