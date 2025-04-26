import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:treemate/main_pages/profile_page.dart';
import 'package:treemate/profile/widgets/no_internet_page.dart';
import 'profile_shimmer.dart';

class ProfilePageLoader extends StatefulWidget {
  const ProfilePageLoader({super.key});

  @override
  State<ProfilePageLoader> createState() => _ProfilePageLoaderState();
}

class _ProfilePageLoaderState extends State<ProfilePageLoader> {
  bool _isConnected = true;
  bool _isLoading = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkConnectivity() async {
    setState(() {
      _isLoading = true;
    });

    List<ConnectivityResult> connectivityResults =
        await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResults);
// Added: 3-second delay
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() {
      _isConnected =
          results.isNotEmpty && results.first != ConnectivityResult.none;
//_isLoading = false;
    });
  }

  void _retryConnection() {
    _checkConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ShimmerLoadingWidget();
    } else if (!_isConnected) {
      return NoInternetPage(onRetry: _retryConnection);
    } else {
      return const MyProfilePage();
    }
  }
}
