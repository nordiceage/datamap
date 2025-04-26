
import 'package:flutter/material.dart';
import 'package:treemate/task/controllers/task_controller.dart';
import 'package:treemate/task/models/usertaskmodel.dart';
import 'package:intl/intl.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final TasksController _tasksController = TasksController();
  UserTaskModel? _task;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
    _tasksController.init();
  }

  Future<void> _loadTaskDetails() async {
    try {
      final allUserTasks = await _tasksController.fetchUserTasks();
      final userTaskModel =
      allUserTasks.firstWhere((element) => element.id == widget.taskId);
      setState(() {
        _task = userTaskModel;
        _isLoading = false;
      });
        } catch (error) {
      // Handle API errors here.
      print("Error fetching task details: $error");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error Loading Task Data'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  DateTime _safeParseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('[TasksPage] Error parsing date: $e');
      return DateTime.now();
    }
  }

  String _getTaskInstruction(String taskType) {
    switch (taskType) {
      case 'watering':
        return "Watering is essential for plant health. However, overwatering can be as detrimental as underwatering. Here's a general guideline:\n\n - Check the soil moisture before watering. Stick your finger about 1 inch into the soil. If it feels dry, it's time to water.\n - When watering, water thoroughly until water begins to drain from the bottom of the pot. This ensures that all the roots are moistened.\n - Never let your plant sit in standing water, as this can cause root rot.\n - Watering frequency depends on factors like the plant species, pot size, time of the year, and environment.";
      case 'misting':
        return "Misting involves gently spraying water onto the leaves and surrounding areas of your plant. This helps to increase humidity, which many plants, especially those from tropical regions, enjoy. Here are some key points:\n\n - Use a fine mist spray bottle for an even distribution.\n - Mist in the morning so the leaves can dry off before evening to prevent fungal issues.\n - Avoid misting in direct sunlight as the water droplets can act as lenses and cause scorch marks.\n - Frequency of misting depends on the humidity levels of the surrounding area. Mist more often during dry periods.";
      case 'fertilizing':
        return "Fertilizing is the process of adding nutrients to your plants. Here are the basic steps:\n\n - Choose the right type of fertilizer for your plant's needs. You can choose liquid fertilizers, slow release, or water soluble options.\n - Always follow the directions on the fertilizer package for dosage.\n - Do not over fertilize, as it can cause chemical burns to the roots.\n - The best time to fertilize most plants is during the growing season, which is typically spring and summer.\n - Fertilize after watering so the fertilizer doesn't burn the roots.";
      default:
        return "General care instructions. Follow your basic plant care rules.";
    }
  }

  String _getTaskTitle(String taskType) {
    switch (taskType) {
      case 'watering':
        return 'Water';
      case 'fertilizing':
        return 'Fertilize';
      case 'misting':
        return 'Mist';
      default:
        return 'Task';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _task?.taskType.toUpperCase() ?? 'Task Details',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.more_vert, color: Colors.black),
          )
        ],
      ),
      backgroundColor: const Color(0xFFEFF4F0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _task == null
          ? const Center(child: Text("No data found!"))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40,),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _task!.userPlant?.plant.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _task!.userPlant?.plant.commonName ??
                      'Unknown Plant',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _task!.userPlant?.site?.siteName ??
                      'Not added to a site',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.teal,
                child: _task != null
                    ? _getTaskIcon(_task!.taskType.toLowerCase())
                    : const Icon(Icons.task), // Added null check here
              ),
              const SizedBox(width: 12),
              Text(
                _task != null
                    ? '${_getTaskTitle(_task!.taskType.toLowerCase())} your plant now'
                    : 'Task your plant now', // Added null check here
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  _task != null
                      ? DateFormat('MMM d, y').format(
                      _safeParseDate(_task!.scheduledAt))
                      : '', // Added null check here
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _task != null
                  ? 'How to ${_getTaskTitle(_task!.taskType.toLowerCase())} this plant ?'
                  : "How to Task this plant?", // Added null check here
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _task != null
                  ? _getTaskInstruction(
                  _task!.taskType.toLowerCase())
                  : 'General care instructions. Follow your basic plant care rules.', // Added null check here
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Mark as completed',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Icon _getTaskIcon(String taskType) {
    switch (taskType) {
      case 'watering':
        return const Icon(Icons.water_drop, color: Colors.white, size: 20);
      case 'misting':
        return const Icon(Icons.sanitizer, color: Colors.white, size: 20);
      case 'fertilizing':
        return const Icon(Icons.food_bank, color: Colors.white, size: 20);
      default:
        return const Icon(Icons.task, color: Colors.white, size: 20);
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complete Task?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to mark this task as complete?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                await _completeAndPop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeAndPop() async {
    if (_task != null) {
      await _tasksController.completeTask(widget.taskId);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error in completing task, try again'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}