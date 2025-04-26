import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:treemate/task/models/usertaskmodel.dart';
import 'package:intl/intl.dart';

class EmptyProgressWidget extends StatelessWidget {
  const EmptyProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "You don't have any progress update currently.",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ProgressGraph extends StatelessWidget {
  final List<UserTaskModel> tasks;

  const ProgressGraph({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Completion Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: _getTaskCompletionBarGroups(),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final date = DateTime.now().subtract(Duration(days: value.toInt()));
                        return Text(
                          DateFormat('MMM dd').format(date),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getTaskCompletionBarGroups() {
    final Map<DateTime, int> taskCompletionCount = {};

    for (var task in tasks) {
      if (task.isComplete) {
        final taskDate = DateTime.parse(task.scheduledAt ?? '');
        final date = DateTime(taskDate.year, taskDate.month, taskDate.day);
        taskCompletionCount.update(date, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    final sortedDates = taskCompletionCount.keys.toList()..sort();

    return sortedDates.map((date) {
      return BarChartGroupData(
        x: DateTime.now().difference(date).inDays,
        barRods: [
          BarChartRodData(
            toY: taskCompletionCount[date]?.toDouble() ?? 0,
            color: Colors.green,
            width: 16,
          ),
        ],
      );
    }).toList();
  }
}
