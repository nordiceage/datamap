import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:treemate/task/controllers/task_controller.dart';
import 'package:treemate/task/models/usertaskmodel.dart';
import 'package:treemate/task/subpages/task_details_screen.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TasksController _tasksController = TasksController();
  final ScrollController _scrollController = ScrollController();
  final Set<UserTaskModel> _tasks = {};
  bool _isLoading = false;
  final int _currentPage = 1;
  final int _tasksPerPage = 10;

  @override
  void initState() {
    super.initState();
    _tasksController.init();
    _fetchTasks();
    // _scrollController.addListener(_onScroll); // Commented out pagination listener
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTasks() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedTasks = await _tasksController.fetchUserTasks(
          // page: _currentPage, pageSize: _tasksPerPage); // Commented out pagination parameters
          );
      setState(() {
        _tasks.clear();
        _tasks.addAll(fetchedTasks);
        // _currentPage++; // Commented out pagination increment
      });
    } catch (e) {
      print('Error fetching tasks: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // void _onScroll() {
  //   if (_scrollController.position.pixels ==
  //       _scrollController.position.maxScrollExtent) {
  //     _fetchTasks();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchTasks,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        children: [
          if (_tasks.any((task) {
            final taskDate = _safeParseDate(task.scheduledAt);
            return taskDate != null &&
                _isSameDay(DateTime.now(), taskDate) &&
                !task.isComplete;
          })) ...[
            _buildTaskSectionTitle("Today's Tasks"),
            _buildTaskCards(
                context,
                _tasks.where((task) {
                  final taskDate = _safeParseDate(task.scheduledAt);
                  return taskDate != null &&
                      _isSameDay(DateTime.now(), taskDate) &&
                      !task.isComplete;
                }).toList(),
                isToday: true),
          ],
          if (_tasks.any((task) {
            final taskDate = _safeParseDate(task.scheduledAt);
            return taskDate != null &&
                taskDate.isAfter(DateTime.now()) &&
                !_isSameDay(DateTime.now(), taskDate) &&
                !task.isComplete;
          })) ...[
            _buildTaskSectionTitle("Upcoming Tasks"),
            _buildTaskCards(
                context,
                _tasks.where((task) {
                  final taskDate = _safeParseDate(task.scheduledAt);
                  return taskDate != null &&
                      taskDate.isAfter(DateTime.now()) &&
                      !_isSameDay(DateTime.now(), taskDate) &&
                      !task.isComplete;
                }).toList()),
          ],
          if (_tasks.any((task) {
            final taskDate = _safeParseDate(task.scheduledAt);
            return taskDate != null &&
                taskDate.isBefore(DateTime.now()) &&
                !_isSameDay(DateTime.now(), taskDate) &&
                !task.isComplete;
          })) ...[
            _buildTaskSectionTitle("Overdue Tasks"),
            _buildTaskCards(
                context,
                _tasks.where((task) {
                  final taskDate = _safeParseDate(task.scheduledAt);
                  return taskDate != null &&
                      taskDate.isBefore(DateTime.now()) &&
                      !_isSameDay(DateTime.now(), taskDate) &&
                      !task.isComplete;
                }).toList()),
          ],
          if (_tasks.any((task) => task.isComplete)) ...[
            _buildTaskSectionTitle("Completed Tasks"),
            _buildTaskCards(
                context, _tasks.where((task) => task.isComplete).toList()),
          ],
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  DateTime? _safeParseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      debugPrint('[TasksPage] Error parsing date: $e');
      return null;
    }
  }

  Widget _buildTaskSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTaskCards(BuildContext context, List<UserTaskModel> tasks,
      {bool isToday = false}) {
    // Group tasks by type
    final Map<String, List<UserTaskModel>> groupedTasks = {};
    for (var task in tasks) {
      groupedTasks.putIfAbsent(task.taskType, () => []).add(task);
    }

    return Column(
      children: groupedTasks.entries.map((entry) {
        final taskType = entry.key;
        final taskList = entry.value;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Header
              Row(
                children: [
                  _getTaskIcon(taskType), // Task icon
                  const SizedBox(width: 12.0),
                  Text(
                    _getTaskTitle(taskType),
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),
              // List of plants associated with this task type
              Column(
                children: taskList.map((task) {
                  final plantName =
                      task.userPlant?.plant.commonName ?? 'Unknown Plant';
                  final siteName =
                      task.userPlant?.site?.siteName ?? 'Not added to a site';
                  final plantImageUrl = task.userPlant?.plant.imageUrl ?? '';

                  final taskDate = _safeParseDate(task.scheduledAt);
                  final daysLeft = taskDate != null
                      ? taskDate.difference(DateTime.now()).inDays
                      : 0;

                  return GestureDetector(
                    onTap: () {
                      // Navigate to TaskDetailsScreen and pass the task ID
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskDetailsScreen(taskId: task.id),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Plant image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: CachedNetworkImage(
                                imageUrl: plantImageUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            // Plant details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plantName,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    siteName,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Remaining Days/Button
                            if (isToday)
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to TaskDetailsScreen and pass the task ID
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
                                  'Complete',
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 14.0,
                                    color: Color(0xFF2B9348),
                                  ),
                                ),
                              )
                            //   for overdue task
                            else if (tasks.any((element) =>
                                _safeParseDate(element.scheduledAt)
                                        ?.isBefore(DateTime.now()) ==
                                    true &&
                                !element.isComplete))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (taskDate != null)
                                    Text(
                                      'Due: ${DateFormat('MMM dd').format(taskDate)}',
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TaskDetailsScreen(
                                                  taskId: task.id),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFDEF0E3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
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
                                  )
                                ],
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (daysLeft > 0)
                                    Text(
                                      'In $daysLeft days',
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.green,
                                      ),
                                    ),
                                  if (taskDate != null)
                                    Text(
                                      DateFormat('MMM dd').format(taskDate),
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        const Divider(), // Separator line
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
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

  String _getTaskTitle(String taskType) {
    switch (taskType) {
      case 'WATERING':
        return 'Watering';
      case 'FERTILIZE':
        return 'Fertilizing';
      case 'MISTING':
        return 'Misting';
      default:
        return 'Task';
    }
  }
}
