import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treemate/task/controllers/task_controller.dart';
import 'package:treemate/task/models/usertaskmodel.dart';
import 'task_history_task_model.dart';

class TaskHistoryModel extends ChangeNotifier {
  List<TaskHistoryTask> _tasks = [];
  String _selectedFilter = 'All';
  bool _isLoading = false;
  int _currentPage = 1;
  final int _tasksPerPage = 20;
  final TasksController _tasksController = TasksController();
  String? _errorMessage;
  bool _hasMoreTasks =
      true; // Add this flag to indicate if there are more tasks to fetch

  TaskHistoryModel() {
    _tasksController.init();
    fetchTasks();
  }

  List<TaskHistoryTask> get tasks => _tasks;
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setFilter(String filter) {
    _selectedFilter = filter;
    _currentPage = 1;
    _tasks.clear();
    fetchTasks();
    notifyListeners();
  }

  List<TaskHistoryTask> get filteredTasks {
    if (_selectedFilter == 'All') return _tasks;
    if (_selectedFilter == 'Completed') {
      return _tasks.where((task) => task.status == 'Completed').toList();
    } else if (_selectedFilter == 'Pending') {
      final now = DateTime.now();
      return _tasks.where((task) {
        final taskDate = task.date;
        return task.status == 'Pending' && taskDate.isBefore(now);
      }).toList();
    }
    return _tasks;
  }

  Future<void> fetchTasks() async {
    if (_isLoading || !_hasMoreTasks) {
      return; // Prevent fetching if already loading or no more tasks
    }
    _isLoading = true;
    notifyListeners();
    try {
      final List<UserTaskModel> fetchedTasks =
          await _tasksController.fetchUserTasks();
      final newTasks = fetchedTasks
          .map((userTask) => TaskHistoryTask.fromUserTask(userTask))
          .toList();

      if (newTasks.isNotEmpty) {
        _tasks.addAll(newTasks);
        _currentPage++;
        await _cacheTasksLocally();
      } else {
        _hasMoreTasks = false; // Set flag to false if no more tasks are fetched
      }
    } catch (e) {
      _errorMessage = "Error fetching tasks: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> fetchTasks() async {
  //   if (_isLoading || !_hasMoreTasks) return; // Prevent fetching if already loading or no more tasks
  //   _isLoading = true;
  //   notifyListeners();
  //   try {
  //     final List<UserTaskModel> fetchedTasks = await _tasksController
  //         .fetchUserTasks(page: _currentPage, pageSize: _tasksPerPage);
  //     final newTasks = fetchedTasks
  //         .map((userTask) => TaskHistoryTask.fromUserTask(userTask))
  //         .toList();

  //     if (newTasks.isNotEmpty) {
  //       _tasks.addAll(newTasks);
  //       _currentPage++;
  //       await _cacheTasksLocally();
  //     } else {
  //       _hasMoreTasks = false; // Set flag to false if no more tasks are fetched
  //     }
  //   } catch (e) {
  //     _errorMessage = "Error fetching tasks: $e";
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> _cacheTasksLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => task.toJson()).toList();
    await prefs.setString('cached_tasks', jsonEncode(tasksJson));
  }

  Future<void> loadCachedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTasksJson = prefs.getString('cached_tasks');
    if (cachedTasksJson != null) {
      final List<dynamic> decodedTasks = jsonDecode(cachedTasksJson);
      _tasks =
          decodedTasks.map((json) => TaskHistoryTask.fromJson(json)).toList();
      notifyListeners();
    }
  }
}
