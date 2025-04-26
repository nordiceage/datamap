import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:treemate/main_pages/garden_page.dart';
import 'package:treemate/task/controllers/task_controller.dart';
import 'package:treemate/task/models/usertaskmodel.dart';
import 'package:treemate/task/subpages/task_details_screen.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key}); // Corrected key usage
  @override
  TasksPageState createState() => TasksPageState();
}

class TasksPageState extends State<TasksPage> {
  final TasksController _tasksController = TasksController();
  final ScrollController _scrollController = ScrollController();
  final Set<UserTaskModel> _allTasks = {};
  List<UserTaskModel> _todayTasks = [];
  List<UserTaskModel> _upcomingTasks = [];
  bool _allTodayTasksCompleted = false;
  bool _isLoading = false; // Ensure this is set to false initially
  final int _currentPage = 1;
  final int _tasksPerPage = 10;

  @override
  void initState() {
    super.initState();
    _tasksController.init();
    fetchTasks();
    // _scrollController.addListener(_onScroll); // Commented out pagination listener
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchTasks() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedTasks = await _tasksController.fetchUserTasks(
          // page: _currentPage, pageSize: _tasksPerPage); // Commented out pagination parameters
          );
      setState(() {
        _allTasks.clear(); // Clear the existing tasks to avoid duplication
        _allTasks.addAll(fetchedTasks);
        _updateTaskLists();
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

  void _updateTaskLists() {
    final now = DateTime.now();

    _todayTasks = [];
    _upcomingTasks = [];

    _todayTasks = _allTasks.where((task) {
      final taskDate = _safeParseDate(task.scheduledAt);
      return taskDate != null && _isSameDay(now, taskDate) && !task.isComplete;
    }).toList();

    _upcomingTasks = _allTasks.where((task) {
      final taskDate = _safeParseDate(task.scheduledAt);
      return taskDate != null &&
          taskDate.isAfter(now) &&
          !_isSameDay(now, taskDate) &&
          !task.isComplete;
    }).toList();

    print("All tasks: $_allTasks");
    print('Today\'s Tasks: $_todayTasks');
    print('Upcoming Tasks: $_upcomingTasks');
    _checkIfAllTodayTasksComplete();
  }

  void _checkIfAllTodayTasksComplete() {
    _allTodayTasksCompleted = _todayTasks.every((task) => task.isComplete);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_allTasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: Text(
            'No tasks available. Add a plant or a Task!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    print("Upcoming Tasks Length: ${_upcomingTasks.length}");
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          if (_todayTasks.isNotEmpty && !_allTodayTasksCompleted) ...[
            _buildTaskSectionTitle("Today's Tasks"),
            _buildTaskCards(context, _todayTasks, isToday: true),
          ] else if (_upcomingTasks.isNotEmpty) ...[
            _buildTaskSectionTitle("Upcoming Tasks"),
            _buildTaskCards(context, _upcomingTasks.take(4).toList()),
            if (_upcomingTasks.length > 4) _buildSeeMoreButton(context),
          ] else if (_allTodayTasksCompleted) ...[
            _buildTaskSectionTitle(
                "All Today's Task completed!, Lets plan Upcoming tasks"),
            _buildTaskCards(context, _upcomingTasks.take(4).toList()),
            if (_upcomingTasks.length > 4) _buildSeeMoreButton(context),
          ],
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildSeeMoreButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Align(
        alignment: Alignment.center,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MyGardenPage(),
              ),
            );
          },
          child: const Text(
            'See More',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
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
              Row(
                children: [
                  _getTaskIcon(taskType),
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
                            if (isToday)
                              ElevatedButton(
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
                                  'Complete',
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 14.0,
                                    color: Color(0xFF2B9348),
                                  ),
                                ),
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
                        const Divider(),
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
