import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:location_tracker_app/config/api_constant.dart';
import 'package:location_tracker_app/modal/task_modal.dart';

class EmployeeTaskService {
  final _storage = const FlutterSecureStorage();

  Future<List<EmployeeTaskModal>> getTaskDetails() async {
    // Get sales_person from secure storage
    String? salesPerson = await _storage.read(key: 'sales_person_id');
    String? sid = await _storage.read(key: 'sid');

    if (salesPerson == null) {
      throw Exception("Sales person not found in storage");
    }

    var headers = {'Content-Type': 'application/json', 'Cookie': 'sid=$sid'};

    final url = Uri.parse(
      '${ApiConstants.baseUrl}get_task_details?sales_person=$salesPerson',
    );

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Check if the response has the expected structure
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        // Parse as single EmployeeTaskModal since the API returns the entire response structure
        final taskModal = EmployeeTaskModal.fromJson(data);
        return [taskModal]; // Return as list with single item
      } else {
        throw Exception("Unexpected response format: missing 'message' key");
      }
    } else {
      throw Exception("Failed to fetch tasks: ${response.reasonPhrase}");
    }
  }
}
