import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:location_tracker_app/config/api_constant.dart';
import 'package:location_tracker_app/modal/sales_invoice_id_modal.dart';

class SalesInvoiceIdsService {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = '${ApiConstants.baseUrl}get_all_sales_invoice_ids';

  Future<SalesInvoiceIdsModel?> fetchSalesInvoiceIds() async {
    try {
      print("🔍 Fetching SID from secure storage...");
      String? sid = await _storage.read(key: "sid");
      print("📌 SID: $sid");

      if (sid == null) {
        throw Exception("SID not found in secure storage");
      }

      var headers = {
        'Cookie':
            'sid=$sid; system_user=yes; full_name=najath; user_id=najath%40gmail.com; user_image=',
      };

      print("📡 Sending GET request to: $baseUrl");
      print("📄 Headers: $headers");

      var request = http.Request('GET', Uri.parse(baseUrl));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      print("📥 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        print("📦 Raw Response: $body");

        final data = json.decode(body);
        print("✅ Parsed JSON: $data");

        return SalesInvoiceIdsModel.fromJson(data);
      } else {
        print("❌ Failed: ${response.reasonPhrase}");
        throw Exception("Failed to load invoice IDs: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("🚨 Error: $e");
      throw Exception("Error fetching invoice IDs: $e");
    }
  }
}
