import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userName;
  String? _userEmail;

  bool _isLoading = true;

  // ================= GETTERS =================
  String? get token => _token;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  bool get isLoading => _isLoading;

  // ================= INIT =================
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString('token');
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');

    _isLoading = false;
    notifyListeners();

  }

  // ================= LOGIN =================
  Future<void> login(String token, {String? name, String? email}) async {
    final prefs = await SharedPreferences.getInstance();

    _token = token;
    _userName = name;
    _userEmail = email;

    await prefs.setString('token', token);
    await prefs.setString('user_name', name ?? '');
    await prefs.setString('user_email', email ?? '');

    notifyListeners();
  }

  // ================= UPDATE PROFILE =================
  Future<void> updateProfile({
    String? name,
    String? email,
  }) async {
    if (_token == null) {
      throw Exception("Not logged in");
    }

    final prefs = await SharedPreferences.getInstance();

    final body = <String, dynamic>{};

    if (name != null && name.trim().isNotEmpty) {
      body["name"] = name.trim();
    }

    if (email != null && email.trim().isNotEmpty) {
      body["email"] = email.trim();
    }

    final res = await http.put(
      Uri.parse("https://goodime-app.onrender.com/auth/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      _userName = data["user"]["name"];
      _userEmail = data["user"]["email"];

      await prefs.setString("user_name", _userName ?? "");
      await prefs.setString("user_email", _userEmail ?? "");

      notifyListeners();
    } else {
      throw Exception(data["error"] ?? "Update failed");
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    _token = null;
    _userName = null;
    _userEmail = null;

    await prefs.remove('token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');

    notifyListeners();
  }
}
