import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String? _userId;

  String? get userId => _userId;

  // Memuat userId dari SharedPreferences saat aplikasi dibuka
  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    notifyListeners();
  }

  // Menyimpan userId ke SharedPreferences dan Provider
  Future<void> setUserId(String userId) async {
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    notifyListeners();
  }

  // Menghapus userId dari SharedPreferences dan Provider
  Future<void> clearUserId() async {
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }
}
