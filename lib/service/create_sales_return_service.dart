import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:location_tracker_app/config/api_constant.dart';

class CreateSalesReturnService {
  final String url = '${ApiConstants.baseUrl}create_sales_return';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  /// Fetch SID from secure storage
  Future<String?> _getSid() async {
    return await storage.read(key: "sid");
  }

  Future<http.Response> createSalesReturn({
    required String invoiceName,
    required String productName,
    required int qty,
    required String reason,
    required String buyingDate,
    String? notes,
  }) async {
    final sid = await _getSid();
    if (sid == null || sid.isEmpty) {
      throw Exception("SID not found in storage");
    }

    final headers = {'Content-Type': 'application/json', 'Cookie': 'sid=$sid'};

    final body = json.encode({
      "invoice_name": invoiceName,
      "product_name": productName,
      "qty": qty,
      "reason": reason,
      "buying_date": buyingDate,
      "notes": notes ?? "",
    });

    // Debug prints
    print("🔹 [SalesReturnService] API URL: $url");
    print("🔹 [SalesReturnService] Headers: $headers");
    print("🔹 [SalesReturnService] Body: $body");

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    // Print full response
    print("🔹 [SalesReturnService] Status Code: ${response.statusCode}");
    print("🔹 [SalesReturnService] Response Body: ${response.body}");

    return response;
  }
}
