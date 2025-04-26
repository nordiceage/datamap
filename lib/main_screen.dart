//this page is used for main navigation. do not edit!
import 'package:flutter/material.dart';
import 'package:treemate/profile/loads/profile_loader.dart';
import 'main_pages/home.dart';
import 'main_pages/community_page.dart';
//import 'profile_page.dart';
import 'bottom_navigation.dart';
import 'package:treemate/garden/loads/garden_loader.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<int> _navigationStack = [0];

  final List<Widget> _pages = [
    const MyHomePage(title: 'Home'),
    const GardenPageLoader(),
    const CommunityPage(),
    const ProfilePageLoader(),
  ];

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _navigationStack.add(index);
      });
    }
  }

  bool _handlePopPage() {
    if (_navigationStack.length > 1) {
      setState(() {
        _navigationStack.removeLast();
        _currentIndex = _navigationStack.last;
      });
      return false;
    }
    return true; //thi will allow the app to be closed if we're at the first page
  }

  @override
  Widget build(BuildContext context) {
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