import 'package:flutter/material.dart';
import 'package:treemate/plant/models/plant_model.dart';
import 'package:treemate/task/add_task_module/add_update_plant_task1.dart';
import 'package:treemate/plant/controllers/plant_controller.dart';
import 'package:treemate/task/models/usertaskmodel.dart';
import 'package:fl_chart/fl_chart.dart';

class PlantSettingsWidget extends StatefulWidget {
  final PlantModel plant;
  final List<UserTaskModel> tasks;

  const PlantSettingsWidget(
      {super.key, required this.plant, required this.tasks});

  @override
  _PlantSettingsWidgetState createState() => _PlantSettingsWidgetState();
}

class _PlantSettingsWidgetState extends State<PlantSettingsWidget> {
  final PlantsController _plantsController = PlantsController();
  List<ActivityItem> _activities = [];
  double _completionPercentage = 0.0;
  bool _isLoading = true;
  // PlantModel? _plantInfo;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _plantsController.ensureInitialized();

    // Calculate completion percentage
    _completionPercentage = _calculateCompletionPercentage(widget.tasks);

    // Update activities based on fetched tasks
    _activities = _mapTasksToActivities(widget.tasks);

    // Fetch plant info
    // _plantInfo = await _plantsController.getPlantById(widget.plant.plantId);

    setState(() {
      _isLoading = false;
    });
  }

  double _calculateCompletionPercentage(List<UserTaskModel> tasks) {
    int totalTasks = tasks.length;
    int activeTasks = tasks.where((task) => task.isComplete).length;
    return totalTasks > 0 ? (activeTasks / totalTasks) * 100 : 0.0;
  }

  List<ActivityItem> _mapTasksToActivities(List<UserTaskModel> tasks) {
    return tasks.map((task) {
      return ActivityItem(
        title: task.taskType,
        subtitle: task.description ?? '',
        icon: Icons.task,
        iconBackgroundColor: Colors.blue,
        isEnabled: !task.isComplete,
      );
    }).toList();
  }

  // void _handleSettingsTap() {
  //   print('Settings tapped');
  // }

  Future<void> _removePlant(BuildContext context) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to remove this plant?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await _plantsController.deleteUserPlant(widget.plant.id);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove plant: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Progress Card with explicit white background
              Card(
                elevation: 2,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    children: [
                      const Text(
                        'Percentage of Tasks Completed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.4,
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: _completionPercentage,
                                    title:
                                        '${_completionPercentage.toStringAsFixed(1)}%',
                                    radius: MediaQuery.of(context).size.width *
                                        0.15,
                                    titleStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.grey[200],
                                    value: 100 - _completionPercentage,
                                    title: 100 - _completionPercentage > 0
                                        ? '${(100 - _completionPercentage).toStringAsFixed(1)}%'
                                        : '',
                                    radius: MediaQuery.of(context).size.width *
                                        0.15,
                                  ),
                                ],
                                centerSpaceRadius:
                                    MediaQuery.of(context).size.width * 0.1,
                                sectionsSpace: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 15),
                      // const Text(
                      //   'Complete the settings for automated reminders and accurate plant care suggestions.',
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //     color: Colors.grey,
                      //     fontSize: 14,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Activities/Task',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              _buildActivityToggles(context),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Plant Info',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 2,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.plant.commonName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(widget.plant.description ?? ''),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _removePlant(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Remove Plant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityToggles(BuildContext context) {
    final Map<String, bool> activityTypes = {
      'Watering': widget.tasks.any((task) => task.taskType == 'WATERING'),
      'Fertilizing': widget.tasks.any((task) => task.taskType == 'FERTILIZE'),
      'Misting': widget.tasks.any((task) => task.taskType == 'MISTING'),
    };

    return Column(
      children: activityTypes.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: ListTile(
            leading: Icon(
              _getTaskIcon(entry.key),
              color: _getTaskIconColor(entry.key),
            ),
            title: Text(entry.key),
            trailing: Switch(
              value: entry.value,
              onChanged: (bool value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SchedulePage(
                      taskName: entry.key,
                      plantID: widget.plant.id,
                      plant: widget.plant,
                    ),
                  ),
                );
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SchedulePage(
                    taskName: entry.key,
                    plantID: widget.plant.id,
                    plant: widget.plant,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  IconData _getTaskIcon(String taskType) {
    switch (taskType) {
      case 'Watering':
        return Icons.water_drop;
      case 'Fertilizing':
        return Icons.eco;
      case 'Misting':
        return Icons.spa;
      default:
        return Icons.task;
    }
  }

  Color _getTaskIconColor(String taskType) {
    switch (taskType) {
      case 'Watering':
        return Colors.blue;
      case 'Fertilizing':
        return Colors.green;
      case 'Misting':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
