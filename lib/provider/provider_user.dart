import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _userId;

  String? get userId => _userId;

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners(); // Memberi tahu widget lain bahwa ada perubahan data
  }

  void clearUserId() {
    _userId = null;
    notifyListeners();
  }
}
