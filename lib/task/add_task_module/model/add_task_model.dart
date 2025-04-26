//add_task_model.dart
class TaskTypeModel {
  String name;
  String id;

  TaskTypeModel({required this.name, required this.id});
  factory TaskTypeModel.fromJson(Map<String, dynamic> json) {
    return TaskTypeModel(
      name: json['name'] as String,
      id: json['id'] as String,
    );
  }
}


class AutomatedTaskModel {
  String frequency;
  String time;
  String?  lastDone;
  String? taskType;
  AutomatedTaskModel({
    required this.frequency,
    required this.time,
    this.taskType,
    this.lastDone
  });
  factory AutomatedTaskModel.fromJson(Map<String, dynamic> json) {
    return AutomatedTaskModel(
      frequency: json['frequency'] as String,
      time: json['time'] as String,
      taskType: json['taskType'] as String?,
      lastDone: json['lastDone'] as String?,
    );
  }
}