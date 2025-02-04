import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getDownloadLink(String downloadUrl) async {
  const String baseUrl = "https://freepik-downloader-api.p.rapidapi.com/external-api/freepik-premium";
  const String apiKey = "7ba0c7d08dmsh3c6d10bd4556e1ep15841ejsn450628965c6b";
  const String apiHost = "freepik-downloader-api.p.rapidapi.com";


  try {
    if (downloadUrl.isEmpty) {
      throw ApiException('Download URL cannot be empty');
    }

    // Match Python's structure exactly
    final querystring = {
      "url": downloadUrl
    };
    final payload = {
      "download": "true"
    };
    final headers = {
      "x-rapidapi-key": apiKey,
      "x-rapidapi-host": apiHost,
      "Content-Type": "application/json"
    };

    // Make sure to encode payload as JSON
    final response = await http.post(
      Uri.parse(baseUrl).replace(queryParameters: querystring),
      headers: headers,
      body: jsonEncode(payload),  // This is important
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw ApiException('Request timed out');
      },
    );

    if (response.statusCode != 200) {
      throw ApiException(
        'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    // First parse the raw JSON response
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    // For debugging
    print('Raw response: $jsonResponse');

    // Instead of using modelplusFromJson directly, let's handle the response manually
    final downloadLink = jsonResponse['download_link'] as String;
    if (downloadLink.isEmpty) {
      throw ApiException('Received empty download link');
    }

    return downloadLink;

  } on http.ClientException catch (e) {
    throw ApiException('Network error: $e');
  } on FormatException catch (e) {
    throw ApiException('Failed to parse response: $e');
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Unexpected error: ');
  }
}

Future<String> getLicenceLink(String downloadUrl) async {
  const String baseUrl = "https://envato-downloader-api1.p.rapidapi.com/external-api/envato";
  const String apiKey = "7ba0c7d08dmsh3c6d10bd4556e1ep15841ejsn450628965c6b";
  const String apiHost = "envato-downloader-api1.p.rapidapi.com";

  try {
    if (downloadUrl.isEmpty) {
      throw ApiException('Download URL cannot be empty');
    }

    // Match Python's structure exactly
    final querystring = {
      "url": downloadUrl
    };
    final payload = {
      "download": "true"
    };
    final headers = {
      "x-rapidapi-key": apiKey,
      "x-rapidapi-host": apiHost,
      "Content-Type": "application/json"
    };

    // Make sure to encode payload as JSON
    final response = await http.post(
      Uri.parse(baseUrl).replace(queryParameters: querystring),
      headers: headers,
      body: jsonEncode(payload),  // This is important
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw ApiException('Request timed out');
      },
    );

    if (response.statusCode != 200) {
      throw ApiException(
        'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    // First parse the raw JSON response
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    // For debugging
    print('Raw response: $jsonResponse');

    // Instead of using modelplusFromJson directly, let's handle the response manually
    final downloadLink = jsonResponse['downloads']['licence_download']['link'] as String;
    if (downloadLink.isEmpty) {
      throw ApiException('Received empty download link');
    }

    return downloadLink;

  } on http.ClientException catch (e) {
    throw ApiException('Network error: $e');
  } on FormatException catch (e) {
    throw ApiException('Failed to parse response: $e');
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Unexpected error: $e');
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException: $message (Status Code: $statusCode)';
    }
    return 'ApiException: $message';
  }
}