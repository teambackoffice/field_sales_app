import 'package:flutter/material.dart';
import 'package:location_tracker_app/view/mainscreen/tasks/tasks.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final Function(Task) onStatusChanged;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.onStatusChanged,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Task currentTask;

  @override
  void initState() {
    super.initState();
    currentTask = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: const Color(0xFF764BA2),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard('Customer Information', Icons.person, [
              _buildDetailRow('Name', currentTask.customerName),
            ]),
            const SizedBox(height: 16),
            _buildDetailCard('Task Timeline', Icons.schedule, [
              _buildDetailRow('Start Date', _formatDate(currentTask.startDate)),
              _buildDetailRow('End Date', _formatDate(currentTask.endDate)),
              _buildDetailRow('Duration', _calculateDuration()),
            ]),
            const SizedBox(height: 16),
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildDescriptionCard(),
            if (currentTask.remarks != null && currentTask.remarks!.isNotEmpty)
              const SizedBox(height: 16),
            if (currentTask.remarks != null && currentTask.remarks!.isNotEmpty)
              _buildRemarksCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showStatusDialog,
        backgroundColor: const Color(0xFF764BA2),
        label: const Text(
          'Change Status',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF764BA2)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF764BA2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.flag, color: Color(0xFF764BA2)),
                SizedBox(width: 8),
                Text(
                  'Current Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF764BA2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: currentTask.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: currentTask.status.color.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    currentTask.status.icon,
                    color: currentTask.status.color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    currentTask.status.displayName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: currentTask.status.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.description, color: Color(0xFF764BA2)),
                SizedBox(width: 8),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF764BA2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              currentTask.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.comment, color: Color(0xFF764BA2)),
                SizedBox(width: 8),
                Text(
                  'Remarks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF764BA2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              currentTask.remarks ?? "",
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _calculateDuration() {
    final difference = currentTask.endDate.difference(currentTask.startDate);
    return '${difference.inDays + 1} days';
  }

  void _showStatusDialog() {
    final TextEditingController remarksController = TextEditingController();
    TaskStatus? selectedStatus = currentTask.status;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Change Task Status'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...TaskStatus.values.map((status) {
                      return RadioListTile<TaskStatus>(
                        value: status,
                        groupValue: selectedStatus,
                        onChanged: (TaskStatus? value) {
                          setStateDialog(() {
                            selectedStatus = value!;
                          });
                        },
                        title: Text(status.displayName),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                    TextField(
                      controller: remarksController,
                      decoration: InputDecoration(
                        labelText: "Remarks (optional)",
                        hintText: "Add a note about this status change...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF764BA2),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (selectedStatus != null) {
                      _updateStatus(
                        selectedStatus!,
                        remarks: remarksController.text.trim().isEmpty
                            ? null
                            : remarksController.text.trim(),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateStatus(TaskStatus newStatus, {String? remarks}) {
    setState(() {
      currentTask.status = newStatus;
      currentTask.remarks = remarks; // store remarks in the task model
    });

    widget.onStatusChanged(currentTask);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Task updated to ${newStatus.displayName}'
          '${remarks != null ? " (Remarks: $remarks)" : ""}',
        ),
        backgroundColor: newStatus.color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
