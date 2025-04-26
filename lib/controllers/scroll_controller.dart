// scroll_controllers.dart
import 'package:flutter/material.dart';

class ScrollControllers extends ChangeNotifier {
  final ScrollController homeController = ScrollController();
  final ScrollController gardenController = ScrollController();
  final ScrollController communityController = ScrollController();
  final ScrollController profileController = ScrollController();
}