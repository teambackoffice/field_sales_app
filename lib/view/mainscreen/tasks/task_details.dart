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
        backgroundColor: Color(0xFF764BA2),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showStatusDialog,
        backgroundColor: Color(0xFF764BA2),
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
                Icon(icon, color: Color(0xFF764BA2)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
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
              children: [
                Icon(Icons.flag, color: Color(0xFF764BA2)),
                const SizedBox(width: 8),
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
              children: [
                Icon(Icons.description, color: Color(0xFF6764BA2)),
                const SizedBox(width: 8),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _calculateDuration() {
    final difference = currentTask.endDate.difference(currentTask.startDate);
    return '${difference.inDays + 1} days';
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Task Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: TaskStatus.values.map((status) {
              return ListTile(
                leading: Icon(status.icon, color: status.color),
                title: Text(status.displayName),
                trailing: currentTask.status == status
                    ? Icon(Icons.check, color: status.color)
                    : null,
                onTap: () {
                  _updateStatus(status);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _updateStatus(TaskStatus newStatus) {
    setState(() {
      currentTask.status = newStatus;
    });
    widget.onStatusChanged(currentTask);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task status updated to ${newStatus.displayName}'),
        backgroundColor: newStatus.color,
      ),
    );
  }
}
