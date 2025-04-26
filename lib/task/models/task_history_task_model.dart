import 'package:treemate/task/models/usertaskmodel.dart';

class TaskHistoryTask {
  final String id;
  final String title;
  final String status;
  final DateTime date;
  final String? plantName;
  final String siteName;

  TaskHistoryTask(
      {required this.id,
      required this.title,
      required this.status,
      required this.date,
      this.plantName,
      required this.siteName});

  factory TaskHistoryTask.fromUserTask(UserTaskModel userTask) {
    return TaskHistoryTask(
      id: userTask.id,
      title: userTask.taskType,
      status: userTask.isComplete ? 'Completed' : 'Pending',
      date: DateTime.parse(userTask.scheduledAt!),
      plantName: userTask.userPlant?.plant.commonName,
      siteName: userTask.userPlant?.site?.siteName ?? 'Site not added',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'date': date.toIso8601String(),
      'plantName': plantName,
      'siteName': siteName,
    };
  }

  factory TaskHistoryTask.fromJson(Map<String, dynamic> json) {
    return TaskHistoryTask(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      date: DateTime.parse(json['date']),
      plantName: json['plantName'],
      siteName: json['siteName'],
    );
  }
}
