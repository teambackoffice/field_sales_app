import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:location_tracker_app/config/api_constant.dart';

class UpdateTaskStatus {
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = "${ApiConstants.baseUrl}update_status";

  /// Update task status API
  Future<Map<String, dynamic>?> updateTaskStatus({
    required String taskName,
    required String status,
  }) async {
    try {
      // Get sid from secure storage
      String? sid = await _storage.read(key: "sid");

      if (sid == null) {
        throw Exception("SID not found in storage. Please login again.");
      }

      var headers = {'Content-Type': 'application/json', 'Cookie': 'sid=$sid'};

      var url = Uri.parse(_baseUrl); // ✅ removed `.update_status` mistake

      var request = http.Request('POST', url);
      request.body = json.encode({"task_name": taskName, "status": status});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String resBody = await response.stream.bytesToString();
        var decoded = json.decode(resBody);

        return decoded;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
