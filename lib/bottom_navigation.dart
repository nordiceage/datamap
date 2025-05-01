import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class BottomNavigationWidget extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  
  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _BottomNavigationWidgetState createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  // Added _isConnected variable to track internet connection status
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    // Check connectivity status when the widget initializes
    _checkConnectivity();
  }

  // Method to check internet connectivity status
  Future<void> _checkConnectivity() async {
    // Listen for changes in connectivity
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final latestResult = results.last; // Get the latest result
      setState(() {
        _isConnected = latestResult != ConnectivityResult.none; // Update _isConnected based on the result
      });
    });

    // Check the initial connectivity status
    var initialResult = await (Connectivity().checkConnectivity());
    setState(() {
      _isConnected = initialResult != ConnectivityResult.none; // Update _isConnected based on the initial result
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Build the BottomNavigationBar widget
    return Container(
      height: 70, // Set the height of the BottomNavigationBar
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // Home navigation item
          BottomNavigationBarItem(
            icon: Icon(Symbols.home),
            label: 'Home',
          ),
          // My Garden navigation item
          BottomNavigationBarItem(
            icon: Icon(Symbols.potted_plant),
            label: 'My Garden',
          ),
          // Community navigation item
          BottomNavigationBarItem(
            icon: Icon(Symbols.partner_exchange),
            label: 'Community',
          ),
          // Profile navigation item
          BottomNavigationBarItem(
            icon: Icon(Symbols.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: widget.currentIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.secondaryColor, // Set the color of the unselected items
        // Handle the onTap event
        onTap: (index) {
          // Check if the selected index requires internet connection
          if ((index == 2 || index == 3) && !_isConnected) {
            // Show a SnackBar if offline and the feature requires internet
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('This feature is not available offline.'),
              ),
            );
          } else {
            // Call the provided onTap callback
            widget.onTap(index);
          }
        },
      ),
    );
  }
}