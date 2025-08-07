import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:location_tracker_app/config/api_constant.dart';
import 'package:location_tracker_app/modal/payment_entry_draft_status.dart';

class PaymentEntryDraftService {
  static const _storage = FlutterSecureStorage();
  final String url = '${ApiConstants.baseUrl}payment_entry_status';

  Future<PaymentEntryDraftStatusModal> fetchPaymentEntryStatus({
    required String customerName,
  }) async {
    try {
      // Retrieve SID from secure storage
      String? sid = await _storage.read(key: 'sid');

      if (sid == null) {
        throw Exception("SID not found. Please login again.");
      }

      // Setup headers
      var headers = {'Cookie': 'sid=$sid; system_user=yes;'};

      // Build URI
      final uri = Uri.parse("$url?customer_name=$customerName");

      // Make request
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return paymentEntryDraftStatusModalFromJson(response.body);
      } else {
        throw Exception(
          "Failed to load payment entry status: ${response.statusCode} - ${response.reasonPhrase} - ${response.body}",
        );
      }
    } catch (e, stackTrace) {
      // Catch any error (network, JSON parsing, etc.)

      throw Exception(
        "An error occurred while fetching payment entry status: $e",
      );
    }
  }
}
