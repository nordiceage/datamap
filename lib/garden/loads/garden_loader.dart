import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:treemate/garden/loads/garden_shimmer.dart';
import 'package:treemate/main_pages/garden_page.dart';
import 'package:treemate/profile/widgets/no_internet_page.dart';

class GardenPageLoader extends StatefulWidget {
  const GardenPageLoader({super.key});

  @override
  State<GardenPageLoader> createState() => _GardenPageLoaderState();
}

class _GardenPageLoaderState extends State<GardenPageLoader> {
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

    List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() {
      _isConnected =
          results.isNotEmpty && results.first != ConnectivityResult.none;
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
      return const GardenShimmerLoadingWidget();
    } else if (!_isConnected) {
      return NoInternetPage(onRetry: _retryConnection);
    } else {
      return const MyGardenPage();
    }
  }
}
