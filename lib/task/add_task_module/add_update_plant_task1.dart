import 'package:flutter/material.dart';
import 'package:treemate/plant/models/plant_model.dart';
import 'package:treemate/task/add_task_module/fertilizing/auto_fertilizing_page.dart';
import 'package:treemate/task/add_task_module/fertilizing/custom_fertilizing_task.dart';
import 'package:treemate/task/add_task_module/misting/auto_misting_page.dart';
import 'package:treemate/task/add_task_module/misting/custom_misting_task.dart';
import 'package:treemate/task/add_task_module/progress/auto_progress_page.dart';
import 'package:treemate/task/add_task_module/progress/custom_progress_update_task.dart';
import 'package:treemate/task/add_task_module/watering/auto_watering_page.dart';
import 'package:treemate/task/add_task_module/watering/custom_watering_task.dart';
import 'package:treemate/task/controllers/task_controller.dart';

class AddTaskPage extends StatefulWidget {
  final PlantModel plant;

  const AddTaskPage({super.key, required this.plant});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TasksController _tasksController = TasksController();
  Map<String, bool> tasks = {};

  @override
  void initState() {
    super.initState();
    _tasksController.init();
    _fetchPlantData();
  }

  Future<void> _fetchPlantData() async {
    setState(() {
      tasks = {
        'Watering': false,
        'Misting': false,
        'Fertilizing': false,
        'Progress Update': false,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Plant Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: widget.plant.imageUrl != null
                          ? NetworkImage(widget.plant.imageUrl!)
                          : const AssetImage('assets/image/plant.png') as ImageProvider,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.plant.commonName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.plant.siteName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Task List
            ...tasks.keys.map((task) => TaskToggleTile(
                  taskName: task,
                  isEnabled: tasks[task]!,
                  onChanged: (value) {
                    setState(() {
                      tasks[task] = value;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SchedulePage(
                            taskName: task,
                            plantID: widget.plant.id,
                            plant: widget.plant),
                      ),
                    );
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SchedulePage(
                            taskName: task,
                            plantID: widget.plant.id,
                            plant: widget.plant),
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFE8F0F1),
    );
  }
}

class TaskToggleTile extends StatelessWidget {
  final String taskName;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTap;

  const TaskToggleTile({super.key, 
    required this.taskName,
    required this.isEnabled,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          leading: Icon(
            taskName == 'Watering'
                ? Icons.water_drop
                : taskName == 'Misting'
                    ? Icons.sanitizer
                    : taskName == 'Fertilizing'
                        ? Icons.spa
                        : taskName == 'Progress Update'
                            ? Icons.update
                            : Icons.help_outline,
            color: taskName == 'Watering'
                ? Colors.blue
                : taskName == 'Misting'
                    ? Colors.teal
                    : taskName == 'Fertilizing'
                        ? Colors.pink
                        : taskName == 'Progress Update'
                            ? Colors.green
                            : Colors.grey,
          ),
          title: Text(
            taskName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          trailing: Switch(
            value: isEnabled,
            onChanged: (value) {
              onChanged(value);
            },
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class SchedulePage extends StatefulWidget {
  final String taskName;
  final String plantID;
  final PlantModel plant;

  const SchedulePage(
      {super.key, required this.taskName, required this.plantID, required this.plant});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String? selectedSchedule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Plant Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: widget.plant.imageUrl != null
                          ? NetworkImage(widget.plant.imageUrl!)
                          : const AssetImage('assets/image/plant.png'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.plant.commonName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.plant.siteName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Select Schedule Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            ScheduleOptionTile(
              title: 'Automated Schedule',
              isSelected: selectedSchedule == 'Automated Schedule',
              onTap: () {
                setState(() {
                  selectedSchedule = 'Automated Schedule';
                });
                _navigateToScheduleDetail('Automated');
              },
            ),
            ScheduleOptionTile(
              title: 'Custom Schedule',
              isSelected: selectedSchedule == 'Custom Schedule',
              onTap: () {
                setState(() {
                  selectedSchedule = 'Custom Schedule';
                });
                _navigateToScheduleDetail('Custom');
              },
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFE8F0F1),
    );
  }

  void _navigateToScheduleDetail(String scheduleType) {
    // Navigate to different pages based on taskName and scheduleType
    switch (widget.taskName) {
      case 'Watering':
        if (scheduleType == 'Automated') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LastWateredPage(plant: widget.plant),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CustomSchedulePage(plantID: widget.plant.id),
            ),
          );
        }
        break;
      case 'Misting':
        if (scheduleType == 'Automated') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LastMistedPage(plant: widget.plant),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CustomMistingSchedulePage(plantID: widget.plant.id),
            ),
          );
        }
        break;
      case 'Fertilizing':
        if (scheduleType == 'Automated') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LastFertilizedPage(plant: widget.plant),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CustomfertilizingSchedulePage(plantID: widget.plant.id),
            ),
          );
        }
        break;
      case 'Progress Update':
        if (scheduleType == 'Automated') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HowIsYourPlantPage(plant: widget.plant),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CustomProgressSchedulePage(plantID: widget.plant.id),
            ),
          );
        }
        break;
      default:
        // Optionally handle unknown tasks
        break;
    }
  }
}

class ScheduleOptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const ScheduleOptionTile({super.key, 
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          leading: Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: Colors.green,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: onTap,
        ),
      ),
    );
  }
}
