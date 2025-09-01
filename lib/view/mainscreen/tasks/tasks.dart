import 'package:flutter/material.dart';
import 'package:location_tracker_app/view/mainscreen/tasks/task_details.dart';

// Task model
class Task {
  final String id;
  final String customerName;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String priority;
  TaskStatus status;

  Task({
    required this.id,
    required this.customerName,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.priority,
    required this.status,
  });
}

enum TaskStatus { inProgress, completed, cancelled, overdue }

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.overdue:
        return 'Overdue';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Color(0xFF764BA2);
      case TaskStatus.overdue:
        return Color(0xFFB71C1C);
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case TaskStatus.inProgress:
        return Icons.play_circle_outline;
      case TaskStatus.completed:
        return Icons.check;
      case TaskStatus.overdue:
        return Icons.warning;
      case TaskStatus.cancelled:
        return Icons.cancel;
    }
  }
}

class EmployeeTasks extends StatefulWidget {
  const EmployeeTasks({super.key});

  @override
  State<EmployeeTasks> createState() => _EmployeeTasksState();
}

class _EmployeeTasksState extends State<EmployeeTasks> {
  List<Task> tasks = [
    Task(
      id: '1',
      customerName: 'John Smith',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      description: 'Website maintenance and updates for the company portal',
      priority: 'High',
      status: TaskStatus.inProgress,
    ),
    Task(
      id: '2',
      customerName: 'Sarah Johnson',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 7)),
      description: 'Mobile app development for restaurant ordering system',
      priority: 'Medium',
      status: TaskStatus.overdue,
    ),
    Task(
      id: '3',
      customerName: 'Mike Wilson',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Database optimization and performance improvements',
      priority: 'High',
      status: TaskStatus.completed,
    ),
    Task(
      id: '4',
      customerName: 'Emily Davis',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 14)),
      description: 'E-commerce platform integration with payment gateway',
      priority: 'Low',
      status: TaskStatus.overdue,
    ),
    Task(
      id: '5',
      customerName: 'Robert Brown',
      startDate: DateTime.now().subtract(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      description: 'Security audit and vulnerability assessment',
      priority: 'High',
      status: TaskStatus.cancelled,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No tasks available',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildTaskCard(task);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          /// Gradient Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF764BA2), Color(0xFF667EEA)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF764BA2).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.task_alt, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 16),

          /// Title + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Employee Tasks',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),

          /// Action button (optional)
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToTaskDetail(task),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.customerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: task.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: task.status.color.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          task.status.icon,
                          size: 16,
                          color: task.status.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.status.displayName,
                          style: TextStyle(
                            color: task.status.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Start: ${_formatDate(task.startDate)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'End: ${_formatDate(task.endDate)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToTaskDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(
          task: task,
          onStatusChanged: (updatedTask) {
            setState(() {
              final index = tasks.indexWhere((t) => t.id == updatedTask.id);
              if (index != -1) {
                tasks[index] = updatedTask;
              }
            });
          },
        ),
      ),
    );
  }
}
