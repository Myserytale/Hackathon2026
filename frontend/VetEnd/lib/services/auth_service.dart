import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  static const String baseUrl = 'https://localhost/api/auth';
  
  bool _isAuthenticated = false;
  String? _token;
  String? _tempToken;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _tempToken = data['token'];
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }
    return false;
  }

  Future<bool> verifyOtp(String code) async {
    if (_tempToken == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-2fa'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tempToken': _tempToken, 'code': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _isAuthenticated = true;
        _tempToken = null;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('OTP verify error: $e');
    }
    return false;
  }

  Future<void> magicLogin() async {
    await login('vet_ana', 'vet123');
    // Note: User must still enter the OTP from the backend console!
  }

  void logout() {
    _isAuthenticated = false;
    _token = null;
    _tempToken = null;
    notifyListeners();
  }
}
