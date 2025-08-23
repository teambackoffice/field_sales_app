// services/special_offer_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:location_tracker_app/config/api_constant.dart';

class GetSpecialOfferService {
  Future<Map<String, dynamic>?> getChundakadanSettings() async {
    final String url = '${ApiConstants.baseUrl}get_chundakadan_settings';

    var request = http.Request('GET', Uri.parse(url));

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
