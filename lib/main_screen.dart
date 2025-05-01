// Import necessary Flutter packages and project-specific files.
import 'package:flutter/material.dart';
import 'package:treemate/profile/loads/profile_loader.dart';
import 'main_pages/home.dart';
import 'main_pages/community_page.dart';
import 'bottom_navigation.dart';
import 'package:treemate/garden/loads/garden_loader.dart';

// MainScreen widget, a stateful widget for the main screen of the app.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}
// State class for MainScreen widget.
class _MainScreenState extends State<MainScreen> {
  // Current selected index in the bottom navigation bar.
  int _currentIndex = 0;
  // Stack to manage navigation history for back button functionality.
  final List<int> _navigationStack = [0];

  // List of widgets corresponding to each page in the bottom navigation.
  final List<Widget> _pages = [
    const MyHomePage(title: 'Home'),
    const GardenPageLoader(),
    const CommunityPage(),
    const ProfilePageLoader(),
  ];
  // Callback function for when a bottom navigation item is tapped.
  void _onItemTapped(int index) {
    // Check if the tapped index is different from the current index.
    if (index != _currentIndex) {
      // Update the state.
      setState(() {
        _currentIndex = index;
        // Add the new index to the navigation stack.
        _navigationStack.add(index);
      });
    }
  }
  // Handles the back button press to navigate within the app.
  bool _handlePopPage() {
    // Check if the navigation stack has more than one item.
    if (_navigationStack.length > 1) {
      // Update the state to go back to the previous page.
      setState(() {
        // Remove the last index from the stack.
        _navigationStack.removeLast();
        // Update the current index to the new last index in the stack.
        _currentIndex = _navigationStack.last;
      });
      // Return false to indicate that the back press has been handled internally.
      return false;
    }
    // If the stack has only one item, return true to allow the app to close.
    return true;
  }

  // Build method for the widget.
  @override
  Widget build(BuildContext context) {
    // PopScope to handle the back button press.
    return PopScope(
      canPop: _navigationStack.length <= 1,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handlePopPage();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationWidget(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}