// services/special_offer_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:location_tracker_app/config/api_constant.dart';

class SpecialOfferService {
  Future<Map<String, dynamic>?> updateSpecialOfferSettings({
    required bool enableStockValidation,
  }) async {
    final String url =
        '${ApiConstants.baseUrl}update_chundakadan_settings?enable_stock_validation=$enableStockValidation';

    var request = http.Request('POST', Uri.parse(url));

    http.StreamedResponse response = await request.send();

    final responseText = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      try {
        final result = jsonDecode(responseText);
        return result;
      } catch (e) {
        return null;
      }
    } else {
      throw Exception(response.reasonPhrase ?? "API call failed");
    }
  }
}
