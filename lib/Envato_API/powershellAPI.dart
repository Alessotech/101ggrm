import 'dart:convert';
import 'package:http/http.dart' as http;

class SimpleHttpRequest {
  static Future<String?> getDownloadUrl(String macroName, String cmdVar1) async {
    try {
      // Encode query parameters
      String encodedMacroName = Uri.encodeComponent(macroName);
      String encodedCmdVar1 = Uri.encodeComponent(cmdVar1);

      // Construct API request
      String targetUrl = "https://stoc-one-api.online:8081/?macro_name=$encodedMacroName&cmd_var1=$encodedCmdVar1";

      // Use CORS Anywhere Proxy
      String corsProxy = "https://cors-pro.onrender.com/";
      String apiUrl = corsProxy + targetUrl;

      print("🔗 Requesting: $apiUrl");

      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': '*/*',
          'Accept-Encoding': 'deflate, gzip',
          'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36',
          'Host': 'stoc-one-api.online',
          'Origin': 'https://your-website.com'
        },
      );

      print("📡 Response Status Code: \${response.statusCode}");
      print("📜 Raw Response: \${response.body}");

      if (response.statusCode == 200) {
        String fixedJson = response.body.replaceAll("'", "\"");
        var data = json.decode(fixedJson);

        if (data['status'] == 'success' && data['download_url'] != null) {
          return data['download_url'];
        } else {
          print("⚠️ Download URL not found in response.");
        }
      } else {
        print("❌ HTTP Error: \${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Request Failed: \$e");
    }
    return null;
  }
}