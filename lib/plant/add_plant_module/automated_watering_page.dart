import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'watering_success_popup.dart';
import 'watering_reminder_popup.dart';

class AutomatedWateringPage extends StatefulWidget {
  final String plantId;
  final String plantName;
  final String plantImageUrl;

  const AutomatedWateringPage({
    super.key,
    required this.plantId,
    required this.plantName,
    required this.plantImageUrl,
  });

  @override
  State<AutomatedWateringPage> createState() => _AutomatedWateringPageState();
}

class _AutomatedWateringPageState extends State<AutomatedWateringPage> {
  String? _selectedOption;
  // final String siteId = '37044411-2f98-49b4-bf0a-71b6b75519f5';

  void _showPopup(BuildContext context, {bool isSkip = false}) async {
    // Prepare the data to be sent
    Map<String, dynamic> plantData = {
      "plantName": widget.plantName,
      "plantId": widget.plantId,
      // "siteId": siteId,
      "lastWateredAt": _getLastWateredValue(),
    };

    // Send the POST request
    final response = await _addPlantForUser(plantData);

    if (response != null) {
      if (isSkip) {
        // Show WateringReminderPopup
        showDialog(
          context: context,
          builder: (BuildContext context) => WateringReminderPopup(
            plantName: widget.plantName,
            plantImageUrl: widget.plantImageUrl,
          ),
        );
      } else {
        // Show WateringSuccessPopup with scheduledAt from response
        showDialog(
          context: context,
          builder: (BuildContext context) => WateringSuccessPopup(
            plantName: widget.plantName,
            plantImageUrl: widget.plantImageUrl,
            scheduledAt: DateTime.parse(response['data']['scheduledAt']),
          ),
        );
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add plant. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to convert selected option to appropriate value
  String _getLastWateredValue() {
    if (_selectedOption == null) {
      return '0';
    } else if (_selectedOption == 'Not sure') {
      return 'NOT_SURE';
    } else if (_selectedOption == 'Last week') {
      return 'LAST_WEEK';
    } else {
      return _selectedOption!.toUpperCase();
    }
  }

  Future<Map<String, dynamic>?> _addPlantForUser(Map<String, dynamic> plantData) async {
    const String endpoint = "/userPlants/addPlantForUser";
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    try {
      // Fetch the access token directly from secure storage
      final String? accessToken = await secureStorage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        print("[ERROR] Access token is missing or empty.");
        return null;
      }

      // Construct the headers
      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      // Construct the API URL
      const String baseUrl =
          "https://treemate-app-azgqccezecdjgzac.centralindia-01.azurewebsites.net/api/v1";
      final Uri url = Uri.parse("$baseUrl$endpoint");

      // Make the POST request
      final http.Response response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(plantData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("[DEBUG] Plant added successfully: ${response.body}");
        // Parse the JSON response
        return jsonDecode(response.body);
      } else {
        print("[ERROR] Failed to add plant: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("[ERROR] Exception in adding plant: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 70,
            leading: Container(
              padding: const EdgeInsets.only(top: 0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Container(
              padding: const EdgeInsets.only(top: 20),
              child: const Text(
                'When did you last water\nyour plant?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            titleSpacing: 0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/image/add_plant_water_q.png',
                height: 200,
              ),
            ),
            const SizedBox(height: 30),
            _buildOptionTile('Today'),
            _buildOptionTile('Yesterday'),
            _buildOptionTile('Last week'),
            _buildOptionTile('Not sure'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _showPopup(context, isSkip: true),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F5E9),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        color: Color(0xFF2B9348),
                        fontSize: 16,
                        fontFamily: 'Open Sans',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showPopup(context, isSkip: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B9348),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Color(0xFFF3F2F2),
                        fontSize: 16,
                        fontFamily: 'Open Sans',
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
  }

  Widget _buildOptionTile(String option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedOption == option
              ? const Color(0xFF2B9348)
              : Colors.transparent,
        ),
      ),
      child: RadioListTile<String>(
        title: Text(
          option,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Open Sans',
          ),
        ),
        value: option,
        groupValue: _selectedOption,
        onChanged: (value) {
          setState(() {
            _selectedOption = value;
          });
        },
        activeColor: const Color(0xFF2B9348),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}