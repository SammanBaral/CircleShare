import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityListener {
  final Connectivity _connectivity = Connectivity();

  Future<bool> get isConnected async {
    try {
      print("🔍 Starting connectivity check...");

      // Check device connectivity
      List<ConnectivityResult> results =
          await _connectivity.checkConnectivity();
      print("📡 Device connectivity results: $results");

      if (results.isEmpty ||
          results.every((result) => result == ConnectivityResult.none)) {
        print("❌ Device reports NO connectivity");
        return false;
      }

      // Debug: Print active connection type
      if (results.contains(ConnectivityResult.wifi)) {
        print("✅ Connected via WiFi");
      } else if (results.contains(ConnectivityResult.mobile)) {
        print("✅ Connected via Mobile Data");
      }

      // Test HTTP request
      try {
        print("🌐 Sending test HTTP request...");

        final response = await http.get(
          Uri.parse('https://www.cloudflare.com/cdn-cgi/trace'),
          headers: {'Cache-Control': 'no-cache'},
        ).timeout(const Duration(seconds: 10));

        print("📥 HTTP response status: ${response.statusCode}");
        print(
            "📄 HTTP response (first 100 chars): ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}");

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print("✅ Internet check SUCCESSFUL!");
          return true;
        } else {
          print("❌ Internet check FAILED! HTTP status: ${response.statusCode}");
        }
      } catch (e) {
        print("❌ HTTP request failed: $e");
      }

      // Fallback: Assume internet is available if WiFi or Mobile is detected
      bool hasWifiOrCellular = results.any((result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi);

      if (hasWifiOrCellular) {
        print("⚠️ Found WiFi/Mobile, assuming internet is available.");
        return true;
      }

      print("❌ All connectivity checks failed.");
      return false;
    } catch (e) {
      print("🚨 Error in connectivity check: $e");
      print("⚠️ Assuming connected due to error in check.");
      return true;
    }
  }
}
