import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:location_tracker_app/config/api_constant.dart';

class CreateSalesReturnService {
  final String url =
      '${ApiConstants.baseUrl}create_sales_return_with_invoice_id';
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
    String? returnAgainst, // optional
    String? returnDate, // optional
    String? customer, // optional
    String? salesPerson, // optional (default from storage)
    List<Map<String, dynamic>>? items, // optional
    String? reason,
    String? buyingDate,
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

    // Build body dynamically
    final Map<String, dynamic> body = {"sales_person": salesPerson ?? id};

    if (returnAgainst != null && returnAgainst.isNotEmpty) {
      body["return_against"] = returnAgainst;
    }
    if (returnDate != null && returnDate.isNotEmpty) {
      body["return_date"] = returnDate;
    }
    if (customer != null && customer.isNotEmpty) {
      body["customer"] = customer;
    }
    if (reason != null && reason.isNotEmpty) {
      body["reason"] = reason;
    }
    if (buyingDate != null && buyingDate.isNotEmpty) {
      body["buying_date"] = buyingDate;
    }
    if (notes != null && notes.isNotEmpty) {
      body["notes"] = notes;
    }
    if (items != null && items.isNotEmpty) {
      body["items"] = items;
    }

    final uri = Uri.parse(url);

    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    // 🟢 Response logs

    return response;
  }
}
