import 'package:flutter/material.dart';
import 'package:location_tracker_app/service/update_task_status.dart';

class UpdateTaskStatusController with ChangeNotifier {
  final UpdateTaskStatus _taskService = UpdateTaskStatus();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> updateTask(String taskName, String status) async {
    _isLoading = true;
    notifyListeners();

    var response = await _taskService.updateTaskStatus(
      taskName: taskName,
      status: status,
    );

    _isLoading = false;
    notifyListeners();

    if (response != null) {
    } else {}
  }
}
