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
      String? salesPerson = await _storage.read(key: "sales_person_id");

      if (sid == null) {
        throw Exception("SID not found in secure storage");
      }
      if (salesPerson == null) {
        throw Exception("Sales Person not found in secure storage");
      }

      var headers = {'Cookie': 'sid=$sid'};

      // ✅ Add sales_person as query parameter
      final url = Uri.parse("$baseUrl?sales_person=$salesPerson");

      var request = http.Request('GET', url);
      request.headers.addAll(headers);

      print("==== API REQUEST START ====");
      print("URL: $url");
      print("Method: ${request.method}");
      print("Headers: ${request.headers}");
      print("==== API REQUEST END ====");

      http.StreamedResponse response = await request.send();

      print("==== API RESPONSE START ====");
      print("Status Code: ${response.statusCode}");
      print("Reason Phrase: ${response.reasonPhrase}");
      print("Headers: ${response.headers}");

      final body = await response.stream.bytesToString();
      print("Raw Body: $body");

      print("==== API RESPONSE END ====");

      if (response.statusCode == 200) {
        final data = json.decode(body);
        print("Parsed JSON: $data");

        final model = SalesInvoiceIdsModel.fromJson(data);
        print("Mapped Model: $model");
        return model;
      } else {
        throw Exception("Failed to load invoice IDs: ${response.reasonPhrase}");
      }
    } catch (e, stack) {
      print("==== API ERROR ====");
      print("Error: $e");
      print("StackTrace: $stack");
      throw Exception("Error fetching invoice IDs: $e");
    }
  }
}
