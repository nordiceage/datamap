// import 'package:flutter/material.dart';
//
// class NoInternetPage extends StatelessWidget {
//   final VoidCallback onRetry;
//
//   const NoInternetPage({Key? key, required this.onRetry}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.wifi_off, size: 80, color: Colors.red),
//             SizedBox(height: 20),
//             Text(
//               'No Internet Connection',
//               style: TextStyle(fontSize: 24, color: Colors.red),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: onRetry,
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // For animations

class NoInternetPage extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetPage({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade200, Colors.brown.shade200],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Plant Animation (Lottie animation of drying plant)
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset('assets/animations/loti_profile_no_net_loading.json'),
              ),
              const SizedBox(height: 20),
              Text(
                'Oops! No Internet',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.brown.shade700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your plant is drying without connection!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.brown.shade500,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  backgroundColor: const Color(0xFFDEF0E3),
                  shadowColor: Colors.black45,
                  elevation: 1,
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF2B9348),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

