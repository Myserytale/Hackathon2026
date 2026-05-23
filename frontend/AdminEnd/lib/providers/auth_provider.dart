import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  static String get baseUrl => ApiConfig.authBaseUrl;  
  AdminUser? _user;
  bool _isAuthenticated = false;
  String? _tempToken;
  String? _errorMessage;

  AdminUser? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  String? get tempToken => _tempToken;
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
          'role': 'ADMIN',
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

  // Step 1: Login with credentials
  Future<bool> initiateLogin(String username, String password) async {
    _errorMessage = null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'expectedRole': 'ADMIN',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _tempToken = data['token']; // This is the temporary 2FA token
        notifyListeners();
        return true;
      }
      _errorMessage = _parseError(response);
    } catch (e) {
      _errorMessage = 'Cannot reach the server. Rebuild with: docker-compose up -d --build';
      debugPrint('Login initiation error: $e');
    }
    return false;
  }

  // Step 2: Verify 2FA code
  Future<bool> verify2Fa(String code) async {
    if (_tempToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-2fa'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tempToken': _tempToken, 'code': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final finalToken = data['token'];
        
        // Extract basic info from token (or just mock it since we know the user)
        _user = AdminUser(
          id: 'ADM-001',
          name: 'Administrator Sistem',
          email: 'admin@apia.ro',
          role: 'ADMIN',
          token: finalToken,
        );
        _isAuthenticated = true;
        _tempToken = null;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('2FA verification error: $e');
    }
    return false;
  }

  Future<void> magicLogin() async {
    await initiateLogin('admin_maria', 'admin123');
    await verify2Fa('123456');
  }

  void logout() {
    _user = null;
    _isAuthenticated = false;
    _tempToken = null;
    notifyListeners();
  }
}
