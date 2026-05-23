import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService extends ChangeNotifier {
  static String get baseUrl => ApiConfig.authBaseUrl;
  
  bool _isAuthenticated = false;
  String? _token;
  String? _tempToken;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get errorMessage => _errorMessage;

  String _parseError(http.Response response) {
    final body = response.body.trim();
    if (body.isNotEmpty) return body;
    if (response.statusCode == 403) {
      return 'Server rejected the request. Rebuild Docker: docker-compose up -d --build';
    }
    return 'Request failed (${response.statusCode})';
  }

  Future<bool> register(String username, String password) async {
    _errorMessage = null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'role': 'VET',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      _errorMessage = _parseError(response);
    } catch (e) {
      _errorMessage = 'Cannot reach the server. Rebuild with: docker-compose up -d --build';
      debugPrint('Register error: $e');
    }
    return false;
  }

  Future<bool> login(String username, String password) async {
    _errorMessage = null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'expectedRole': 'VET',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _tempToken = data['token'];
        return true;
      }
      _errorMessage = _parseError(response);
    } catch (e) {
      _errorMessage = 'Cannot reach the server. Rebuild with: docker-compose up -d --build';
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
    await verifyOtp('123456');
  }

  void logout() {
    _isAuthenticated = false;
    _token = null;
    _tempToken = null;
    _errorMessage = null;
    notifyListeners();
  }
}
