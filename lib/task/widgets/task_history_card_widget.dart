import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:treemate/task/models/task_history_task_model.dart';
import 'package:treemate/task/subpages/task_details_screen.dart';


class TaskCard extends StatelessWidget {
  final TaskHistoryTask task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(task.plantName ?? 'Plant not found'), // Display plant name or placeholder
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.siteName), // Display site name
            Text(
              DateFormat('MMM dd, hh:mm a').format(task.date), // Format date and time
            ),
          ],
        ),
        trailing: task.status == 'Pending'
            ? ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    TaskDetailsScreen(taskId: task.id),
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
            'Pending',
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 14.0,
              color: Color(0xFFC5613B),
            ),
          ),
        )
            : Chip(
          label: Text(task.status),
          backgroundColor: task.status == 'Completed'
              ? Colors.green[100]
              : Colors.orange[100],
        ),
      ),
    );
  }
}