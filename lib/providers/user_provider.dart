import 'package:flutter/material.dart';
import 'package:treemate/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
