import 'package:flutter/material.dart';
import 'package:treemate/plant/models/plant_model.dart';
import 'package:treemate/task/controllers/task_controller.dart';

class LastFertilizedPage extends StatefulWidget {
  final PlantModel plant;

  const LastFertilizedPage({super.key, required this.plant});

  @override
  _LastFertilizedPageState createState() => _LastFertilizedPageState();
}

class _LastFertilizedPageState extends State<LastFertilizedPage> {
  String? selectedOption;
  final TasksController _tasksController = TasksController();

  @override
  void initState() {
    super.initState();
    _tasksController.init();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'When did you last fertilize your plant?',
          style: TextStyle(
            color: Colors.black,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Plant Image
            Center(
              child: Image.asset(
                'assets/image/fertilizer.png',
                height: screenWidth * 0.4,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            // Fertilizing Time Options
            FertilizingOptionTile(
              title: 'TODAY',
              isSelected: selectedOption == 'TODAY',
              onTap: () {
                setState(() {
                  selectedOption = 'TODAY';
                });
              },
            ),
            FertilizingOptionTile(
              title: 'YESTERDAY',
              isSelected: selectedOption == 'YESTERDAY',
              onTap: () {
                setState(() {
                  selectedOption = 'YESTERDAY';
                });
              },
            ),
            SizedBox(height: screenHeight * 0.03),
            // Save Button
            ElevatedButton(
              onPressed: selectedOption == null
                  ? null
                  : () async {
                      await _tasksController.addUserTask({
                        "lastWateredAt": selectedOption!,
                        "userPlantId": widget.plant.id,
                        "taskType": "FERTILIZE",
                        "note": "Fertilizing task scheduled",
                      });
                      _showConfirmationDialog(
                          context, screenWidth, screenHeight);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, screenHeight * 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFE8F0F1),
    );
  }

  void _showConfirmationDialog(
      BuildContext context, double screenWidth, double screenHeight) {
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
                    ? NetworkImage(widget.plant.imageUrl!)
                    : const AssetImage('assets/image/plant.png'),
                  height: screenWidth * 0.3,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  widget.plant.commonName ?? 'Unknown',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Automated fertilizing activity scheduled successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          minimumSize:
                              Size(double.infinity, screenHeight * 0.06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(
                            context,
                            ModalRoute.withName('/main_screen'),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize:
                              Size(double.infinity, screenHeight * 0.06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Go to task',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
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
  }
}

class FertilizingOptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const FertilizingOptionTile({super.key, 
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
            size: screenWidth * 0.06,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.045,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
