import 'package:flutter/material.dart';
import 'package:treemate/plant/models/plant_model.dart';
import 'package:treemate/task/controllers/task_controller.dart';

class HowIsYourPlantPage extends StatelessWidget {
  final PlantModel plant;

  const HowIsYourPlantPage({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How is your plant doing?'),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Information Text
                const Text(
                  'Once per month we’ll ask you to check on the health or overall progress.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                // Plant Image
                Image.asset(
                  'assets/image/progress_plant.png',
                  height: constraints.maxHeight * 0.2,
                ),
                const SizedBox(height: 24),
                // Update Reminder Text
                const Text(
                  'You haven’t updated this month, click on the button below to add details',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Update Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PlantProgressPage(plant: plant)),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFFE8F0F1),
    );
  }
}

class PlantProgressPage extends StatefulWidget {
  final PlantModel plant;

  const PlantProgressPage({super.key, required this.plant});

  @override
  _PlantProgressPageState createState() => _PlantProgressPageState();
}

class _PlantProgressPageState extends State<PlantProgressPage> {
  String? healthStatus = 'Good';
  String note = '';
  double healthValue = 2.0;
  final TasksController _tasksController = TasksController();

  @override
  void initState() {
    super.initState();
    _tasksController.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Update'),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upload/Take a Picture Button
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.camera_alt, size: 50),
                                  onPressed: () {
                                    // Handle Camera Action
                                  },
                                ),
                                const Text('Camera'),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.photo, size: 50),
                                  onPressed: () {
                                    // Handle Gallery Action
                                  },
                                ),
                                const Text('Gallery'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt, color: Colors.green),
                          SizedBox(width: 16),
                          Text('Upload/Take a Picture'),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                // Health Slider
                const Text('Health',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('How is your plant doing currently?'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HealthOption(
                        icon: Icons.sick,
                        label: 'Poor',
                        isSelected: healthValue == 0.0,
                        onTap: () => updateHealth(0.0)),
                    HealthOption(
                        icon: Icons.sentiment_dissatisfied,
                        label: 'Fair',
                        isSelected: healthValue == 1.0,
                        onTap: () => updateHealth(1.0)),
                    HealthOption(
                        icon: Icons.sentiment_satisfied,
                        label: 'Good',
                        isSelected: healthValue == 2.0,
                        onTap: () => updateHealth(2.0)),
                    HealthOption(
                        icon: Icons.sentiment_very_satisfied,
                        label: 'Excellent',
                        isSelected: healthValue == 3.0,
                        onTap: () => updateHealth(3.0)),
                  ],
                ),
                Slider(
                  value: healthValue,
                  min: 0.0,
                  max: 3.0,
                  divisions: 3,
                  onChanged: (value) {
                    setState(() {
                      healthValue = value;
                      updateHealth(value);
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Take Notes
                const Text('Take Notes',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Write something about your plant...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                  ),
                  maxLines: 4,
                  onChanged: (value) {
                    setState(() {
                      note = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Save Button
                ElevatedButton(
                  onPressed: note.isEmpty
                      ? null
                      : () async {
                          await _tasksController.addUserTask({
                            "lastWateredAt": DateTime.now().toIso8601String(),
                            "userPlantId": widget.plant.id,
                            "taskType": "PROGRESS_UPDATE",
                            "note": note,
                          });
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                        children: [
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Image(
                                        image: widget.plant.imageUrl != null
                                            ? NetworkImage(
                                                widget.plant.imageUrl!)
                                            : const AssetImage(
                                                'assets/image/plant.png'),
                                        height: constraints.maxWidth * 0.2,
                                      ),
                                      const SizedBox(height: 16),
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
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Automated progress update activity scheduled successfully',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.update,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '24-11-24',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  'Progress Update',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Spacer(),
                                            Flexible(
                                              child: Text(
                                                'In 10 days',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey,
                                                minimumSize:
                                                    const Size(double.infinity, 50),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                ),
                                              ),
                                              child: const Text('Close'),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // Navigate to task page
                                                Navigator.popUntil(
                                                  context,
                                                  ModalRoute.withName(
                                                      '/main_screen'),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                minimumSize:
                                                    const Size(double.infinity, 50),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: Text('Go to task'),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(Icons.arrow_forward),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFFE8F0F1),
    );
  }

  void updateHealth(double value) {
    setState(() {
      healthValue = value;
      switch (value.toInt()) {
        case 0:
          healthStatus = 'Poor';
          break;
        case 1:
          healthStatus = 'Fair';
          break;
        case 2:
          healthStatus = 'Good';
          break;
        case 3:
          healthStatus = 'Excellent';
          break;
      }
    });
  }
}

class HealthOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const HealthOption({super.key, 
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: isSelected ? Colors.green : Colors.grey.shade300,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
