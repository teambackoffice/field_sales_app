import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:location_tracker_app/config/api_constant.dart';
import 'package:location_tracker_app/modal/sales_order_modal.dart';

class SalesOrderService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String url = '${ApiConstants.baseUrl}get_sales_orders_with_details';

  Future<SalesOrderModal?> getsalesorder() async {
    try {
      print(url);
      final String? sid = await _secureStorage.read(key: 'sid');
      if (sid == null)
        throw Exception('Authentication required. Please login again.');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Cookie': 'sid=$sid'},
      );

      if (response.statusCode == 200) {
        print(response);
        print(response.body);
        print(response.statusCode);
        try {
          final decoded = jsonDecode(response.body);
          return salesOrderModalFromJson(response.body);
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        throw Exception(
          'Failed to load customers. Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(e);
      throw Exception('Network error: $e');
    }
  }
}
