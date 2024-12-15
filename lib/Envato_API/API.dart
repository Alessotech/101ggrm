import 'dart:convert';
import 'package:http/http.dart' as http;

import 'modelp.dart';
Future<String> getDownloadLink(String downloadUrl) async {
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
    final downloadLink = jsonResponse['downloads']['file_download']['link'] as String;
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
// Future<String>  getDownloadLink(String downloadUrl) async {
//
//
//
//
//   try {
//     // Validate input URL
//     if (downloadUrl.isEmpty) {
//       throw ApiException('Download URL cannot be empty');
//     }
//
//     // Prepare request parameters
//     final queryParameters = {
//       "url": downloadUrl
//     };
//
//     final headers = {
//       "x-rapidapi-key": apiKey,
//       "x-rapidapi-host": apiHost,
//       "Content-Type": "application/json"
//     };
//
//     final payload = {
//       "download": "true"
//     };
//
//     // Make the API request
//     final response = await http.post(
//       Uri.parse(baseUrl).replace(queryParameters: queryParameters),
//       headers: headers,
//       body: jsonEncode(payload),
//     ).timeout(
//       Duration(seconds: 30),
//       onTimeout: () {
//         throw ApiException('Request timed out');
//       },
//     );
//
//     // Handle response status
//     if (response.statusCode == 401) {
//       throw ApiException('Invalid API key', statusCode: response.statusCode);
//     } else if (response.statusCode == 429) {
//       throw ApiException('Rate limit exceeded', statusCode: response.statusCode);
//     } else if (response.statusCode != 200) {
//       throw ApiException(
//         'Failed to get download link',
//         statusCode: response.statusCode,
//       );
//     }
//
//     // Parse response
//     try {
//       final responseData = jsonDecode(response.body);
//       final downloadResponse = modelplusFromJson(responseData);
//
//       // Validate response data
//       if (downloadResponse.downloads.fileDownload.link.isEmpty) {
//         throw ApiException('Received empty download link');
//       }
//
//       // Log status for debugging
//       print('Download status: ${downloadResponse.downloads.status}');
//
//       return downloadResponse.downloads.fileDownload.link;
//     } on FormatException catch (e) {
//       throw ApiException('Failed to parse response: $e');
//     }
//   } on http.ClientException catch (e) {
//     throw ApiException('Network error: $e');
//   } catch (e) {
//     if (e is ApiException) rethrow;
//     throw ApiException('Unexpected error: $e');
//   }
// }



// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// import 'modelp.dart';
//
// Future<String> APi(String downUrl) async {
//   var url = "exm";
//
//   var querystring = {
//     "url": "$downUrl"
//   };
//
//   var payload = {"download": "true"};
//   var headers = {
//     "x-rapidapi-key": "7ba0c7d08dmsh3c6d10bd4556e1ep15841ejsn450628965c6b",
//     "x-rapidapi-host": "exm",
//     "Content-Type": "application/json"
//   };
//
//   var response = await http.post(
//     Uri.parse(url).replace(queryParameters: querystring),
//     headers: headers,
//     body: jsonEncode(payload),
//   );
//
//   final Modelplus = modelplusFromJson(response.body);
//
//   print(Modelplus.downloads.status);
//   return Modelplus.downloads.fileDownload.link;
// }

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