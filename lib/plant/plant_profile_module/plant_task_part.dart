import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:treemate/task/models/usertaskmodel.dart';
import 'package:treemate/task/subpages/task_details_screen.dart';

class UpcomingTasksWidget extends StatelessWidget {
  final List<UserTaskModel> tasks;

  const UpcomingTasksWidget({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100], // Background color behind cards
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Upcoming Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...tasks.map((task) => TaskItemWidget(task: task)),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskItemWidget extends StatelessWidget {
  final UserTaskModel task;

  const TaskItemWidget({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final taskDate = DateTime.parse(task.scheduledAt ?? '');
    final formattedDate = DateFormat('MMM dd, yyyy').format(taskDate);

    return Card(
      elevation: 1,
      color: Colors.white, // Card background color
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          // Optional: adds a border
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Optional: adds a gradient or different color
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: ListTile(
          leading: _getTaskIcon(task.taskType),
          title: Text(
            task.taskType,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.grey,
            ),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              // Navigate to TaskDetailsScreen and pass the task ID
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TaskDetailsScreen(taskId: task.id),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDEF0E3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              elevation: 0.0,
            ),
            child: const Text(
              'Complete',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 14.0,
                color: Color(0xFF2B9348),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTaskIcon(String taskType) {
    switch (taskType) {
      case 'WATERING':
        return const Icon(Icons.water_drop, size: 40.0, color: Colors.blue);
      case 'FERTILIZE':
        return const Icon(Icons.eco, size: 40.0, color: Colors.green);
      case 'MISTING':
        return const Icon(Icons.spa, size: 40.0, color: Colors.teal);
      default:
        return const Icon(Icons.task, size: 40.0, color: Colors.grey);
    }
  }
}
