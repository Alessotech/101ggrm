import 'dart:convert';
import 'package:http/http.dart' as http;

class WebDAVAPI {
  final String baseUrl;
  final String username;
  final String password;

  WebDAVAPI({
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  // Basic Auth Header
  String get _basicAuth => 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  Map<String, String> get _headers => {
    'Authorization': _basicAuth,
  };

  /// **Directly gets the WebDAV file download link**
  Future<String?> getDownloadLink(String filePath) async {
    try {
      String downloadUrl = "$baseUrl/$filePath";
      print("📥 Download URL: $downloadUrl");

      // Make a HEAD request to check if the file exists
      var response = await http.head(Uri.parse(downloadUrl), headers: _headers);

      print("📡 Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ File Exists: $downloadUrl");
        return downloadUrl;
      } else {
        print("❌ File Not Found (Status Code: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      print('❌ WebDAV Download Error: $e');
      return null;
    }
  }
}
