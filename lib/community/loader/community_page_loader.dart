
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'dart:io';

class ShimmerCommunityPage extends StatefulWidget {
  final Function onLoadComplete;

  const ShimmerCommunityPage({
    super.key,
    required this.onLoadComplete,
  });

  @override
  _ShimmerCommunityPageState createState() => _ShimmerCommunityPageState();
}

class _ShimmerCommunityPageState extends State<ShimmerCommunityPage> {
  bool _isLoading = true;
  bool _showRetry = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _showRetry = false;
    });

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _showRetry = true;
      });
    });

    try {
      // Simulate network request
      bool hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        throw const SocketException('No Internet connection');
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful load
      widget.onLoadComplete();
    } catch (e) {
      print('Error loading data: $e');
      // We don't set _showRetry here anymore, as it's handled by the timer
    } finally {
      setState(() {
        _isLoading = false;
      });
      // We don't cancel the timer here, as we want it to run for 5 seconds regardless
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 150,
            height: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const Icon(Icons.bookmark_border, size: 24, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_showRetry)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(16),
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 200,
                          color: Colors.white,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 200,
                                height: 24,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                height: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                height: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            Container(
              color: Colors.white,
            ),
          if (_showRetry)
            Center(
              child: FloatingActionButton.extended(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }
}