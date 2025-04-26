import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrentTimeWidget extends StatelessWidget {
  const CurrentTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat('EEEE | hh:mm a').format(DateTime.now()),
      style:Theme.of(context).textTheme.bodySmall);
    //);
  }
}
