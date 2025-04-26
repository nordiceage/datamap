import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class GardenShimmerLoadingWidget extends StatelessWidget {
  const GardenShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // AppBar shimmer
          Container(
            width: double.infinity,
            height: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          // TabBar shimmer
          Container(
            width: double.infinity,
            height: 50,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          // List items shimmer
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
