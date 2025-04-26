import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:treemate/task/controllers/task_controller.dart';

class CustomSchedulePage extends StatefulWidget {
  final String plantID;

  const CustomSchedulePage({super.key, required this.plantID});

  @override
  _CustomSchedulePageState createState() => _CustomSchedulePageState();
}

class _CustomSchedulePageState extends State<CustomSchedulePage> {
  int repeatEveryDays = 4;
  TimeOfDay? selectedTime;
  bool isSaveEnabled = false;
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
        title: const Text('Custom Schedule',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFFEFF5EC),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFEFF5EC),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskRow(),
            const SizedBox(height: 12),
            _buildRepeatEveryRow(context),
            const SizedBox(height: 12),
            _buildSetTimeRow(context),
            const SizedBox(height: 12),
            _buildHelpRow(),
            const Spacer(),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.task_alt, color: Colors.green),
          SizedBox(width: 16),
          Text('Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Spacer(),
          Text('Watering', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRepeatEveryRow(BuildContext context) {
    return GestureDetector(
      onTap: () => _showRepeatEveryBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.green),
            const SizedBox(width: 16),
            const Text('Repeat every',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('$repeatEveryDays days', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSetTimeRow(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSetTimeBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.green),
            const SizedBox(width: 16),
            const Text('Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(selectedTime != null
                ? selectedTime!.format(context)
                : 'Set time', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpRow() {
    return Center(
      child: TextButton.icon(
        icon: const Icon(Icons.help_outline, color: Colors.green),
        label: const Text('Learn how to and when to water this plant?',
            style: TextStyle(color: Colors.green)),
        onPressed: () {},
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: isSaveEnabled ? () => _saveCustomTask() : null,
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all<Size>(const Size(double.infinity, 48)),
          backgroundColor: WidgetStateProperty.all<Color>(
              isSaveEnabled ? Colors.green : Colors.green[100]!),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
          ),
        ),
        child: const Text('Save', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _showRepeatEveryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFEFF5EC),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Repeat Every',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Set the number of days you want to repeat for task name',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: CupertinoPicker(
                  backgroundColor: const Color(0xFFEFF5EC),
                  itemExtent: 50.0,
                  scrollController:
                  FixedExtentScrollController(initialItem: repeatEveryDays - 1),
                  onSelectedItemChanged: (int value) {
                    HapticFeedback.selectionClick();
                    SystemSound.play(SystemSoundType.click);
                    setState(() {
                      repeatEveryDays = value + 1;
                      _checkIfSaveEnabled();
                    });
                  },
                  children: List<Widget>.generate(30, (int index) {
                    return Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                            fontSize: 24,
                            color: index + 1 == repeatEveryDays ? Colors.green : Colors.grey),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Water after every $repeatEveryDays days',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSetTimeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFEFF5EC),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Set Time',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                selectedTime != null
                    ? 'Remind to check the health in ${selectedTime!.format(context)}'
                    : 'Set reminder time',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: false,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (DateTime newTime) {
                    HapticFeedback.selectionClick();
                    SystemSound.play(SystemSoundType.click);
                    setState(() {
                      selectedTime =
                          TimeOfDay(hour: newTime.hour, minute: newTime.minute);
                      _checkIfSaveEnabled();
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveCustomTask() async {
    // await _tasksController.addCustomTask({
    //   "lastWateredAt": "TODAY",
    //   "userPlantId": widget.plantID,
    //   "taskType": "WATERING",
    //   "note": "Watering task scheduled every $repeatEveryDays days at ${selectedTime!.format(context)}",
    // });
    _showSuccessPopup(context);
  }

  void _showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.asset(
                        'assets/success_illustration.png', // Illustration image
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/plant_icon.png',
                        height: 60,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Snake Plant',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Text('Site name', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Custom watering activity scheduled successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.blue, size: 40),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '24-11-24 | 12:30 pm',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text('Water', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'In $repeatEveryDays days',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        foregroundColor: Colors.grey,
                        backgroundColor: const Color(0xFFF1F3F5),
                      ),
                      child: const Text('Close'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.green,
                      ),
                      child: const Row(
                        children: [
                          Text('Go to task'),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
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

  void _checkIfSaveEnabled() {
    setState(() {
      isSaveEnabled = repeatEveryDays > 0 && selectedTime != null;
    });
  }
}
