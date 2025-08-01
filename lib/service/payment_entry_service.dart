import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:location_tracker_app/config/api_constant.dart';
import 'package:location_tracker_app/modal/payment_entry_modal.dart';

class PaymentEntryService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String baseUrl = '${ApiConstants.baseUrl}get_customer_sales_invoices';

  Future<PaymentEntryModal?> getCustomerPaymentEntry({
    required String customer,
  }) async {
    try {
      final String? sid = await _secureStorage.read(key: 'sid');
      if (sid == null)
        throw Exception('Authentication required. Please login again.');

      // Append customer parameter to URL
      final uri = Uri.parse(
        baseUrl,
      ).replace(queryParameters: {'customer': customer});

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json', 'Cookie': 'sid=$sid'},
      );

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);
          return PaymentEntryModal.fromJson(decoded);
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        throw Exception(
          'Failed to load customers. Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
