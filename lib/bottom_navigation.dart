// import 'package:flutter/material.dart';
// import 'package:material_symbols_icons/material_symbols_icons.dart';
// import 'theme.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
//
// class BottomNavigationWidget extends StatefulWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//
//   const BottomNavigationWidget({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   _BottomNavigationWidgetState createState() => _BottomNavigationWidgetState();
// }
//
// class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
//   // Added _isConnected variable
//   bool _isConnected = true;
//
//   @override
//   void initState() {
//     super.initState();
//     // Added connectivity check
//     _checkConnectivity();
//   }
//
//   // Added _checkConnectivity method
//   Future<void> _checkConnectivity() async {
//     Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
//       final latestResult = results.last;
//       setState(() {
//         _isConnected = latestResult != ConnectivityResult.none;
//       });
//     });
//
//     var initialResult = await (Connectivity().checkConnectivity());
//     setState(() {
//       _isConnected = initialResult != ConnectivityResult.none;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 70,
//       child: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Symbols.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Symbols.potted_plant),
//             label: 'My Garden',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Symbols.partner_exchange),
//             label: 'Community',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Symbols.account_circle),
//             label: 'Profile',
//           ),
//         ],
//         currentIndex: widget.currentIndex,
//         selectedItemColor: AppTheme.primaryColor,
//         unselectedItemColor: AppTheme.secondaryColor,
//         // Modified onTap
//         onTap: (index) {
//           if ((index == 2 || index == 3) && !_isConnected) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('This feature is not available offline.'),
//               ),
//             );
//           } else {
//             widget.onTap(index);
//           }
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'theme.dart';

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
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Symbols.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.potted_plant),
            label: 'My Garden',
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.partner_exchange),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: widget.currentIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.secondaryColor,
        onTap: widget.onTap,
      ),
    );
  }
}