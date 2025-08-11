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
      String? sid = await _storage.read(key: "sid");

      if (sid == null) {
        throw Exception("SID not found in secure storage");
      }

      var headers = {'Cookie': 'sid=$sid '};

      var request = http.Request('GET', Uri.parse(baseUrl));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();

        final data = json.decode(body);

        return SalesInvoiceIdsModel.fromJson(data);
      } else {
        throw Exception("Failed to load invoice IDs: ${response.reasonPhrase}");
      }
    } catch (e) {
      throw Exception("Error fetching invoice IDs: $e");
    }
  }
}
