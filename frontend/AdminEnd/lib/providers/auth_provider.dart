import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  static const String baseUrl = 'https://localhost/api/auth';
  
  AdminUser? _user;
  bool _isAuthenticated = false;
  String? _tempToken; // For 2FA step

  AdminUser? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  String? get tempToken => _tempToken;

  // Step 1: Login with credentials
  Future<bool> initiateLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _tempToken = data['token']; // This is the temporary 2FA token
        notifyListeners();
        return true;
      }
    } catch (e) {
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
          name: 'Maria Ionescu',
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

  // Magic Login: Shortcut for demo
  Future<void> magicLogin() async {
    await initiateLogin('admin_maria', 'admin123');
    // Note: User must still enter the OTP from the backend console!
  }

  void logout() {
    _user = null;
    _isAuthenticated = false;
    _tempToken = null;
    notifyListeners();
  }
}
