import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:location_tracker_app/config/api_constant.dart';
import 'package:location_tracker_app/modal/customer_list_modal.dart';

class CustomerListService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<CustomerListModal> fetchCustomerList() async {
    final String url = '${ApiConstants.baseUrl}get_customers';

    print("📡 API CALL: $url"); // PRINT URL

    try {
      final String? sid = await _secureStorage.read(key: 'sid');

      print("🔑 SID From Storage: $sid"); // PRINT SID

      if (sid == null) {
        throw Exception('Authentication required. Please login again.');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Cookie': 'sid=$sid'},
      );

      print(
        "📥 RAW RESPONSE STATUS: ${response.statusCode}",
      ); // PRINT STATUS CODE
      print("📥 RAW RESPONSE BODY: ${response.body}"); // PRINT FULL RAW JSON
      print("📥 RESPONSE HEADERS: ${response.headers}"); // PRINT HEADERS

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);

          print("📘 DECODED JSON: $decoded"); // PRINT JSON AFTER DECODE

          return CustomerListModal.fromJson(decoded);
        } catch (e) {
          print("❌ JSON Parse Error: $e");
          throw Exception('Failed to parse response: $e');
        }
      } else {
        print("❌ ERROR RESPONSE BODY: ${response.body}");
        throw Exception(
          'Failed to load customers. Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ NETWORK ERROR: $e");
      throw Exception('Network error: $e');
    }
  }
}
