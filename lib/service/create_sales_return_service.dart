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

  /// Fetch ID from secure storage
  Future<String?> _getId() async {
    return await storage.read(key: "sales_person_id");
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

    final id = await _getId();
    if (id == null || id.isEmpty) {
      throw Exception("ID not found in storage");
    }

    final headers = {'Content-Type': 'application/json', 'Cookie': 'sid=$sid'};

    final body = json.encode({
      "sales_person": id,
      "invoice_name": invoiceName,
      "product_name": productName,
      "qty": qty,
      "reason": reason,
      "buying_date": buyingDate,
      "notes": notes ?? "",
    });

    final uri = Uri.parse(url);

    final response = await http.post(uri, headers: headers, body: body);

    return response;
  }
}
