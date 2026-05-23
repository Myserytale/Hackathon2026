import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:8080/api/auth';
  
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

  // Magic Login: Shortcut for demo (directly hits the backend if LAST_GENERATED_OTP is known, 
  // but here we just simulate a direct success if the backend allows or bypass logic)
  Future<void> magicLogin() async {
    // For hackathon: we just set the state if backend is mocked, 
    // or we could do a full flow with hardcoded '123456'
    await initiateLogin('admin', 'password');
    await verify2Fa('123456'); // Default testing OTP in AuthController.java
  }

  void logout() {
    _user = null;
    _isAuthenticated = false;
    _tempToken = null;
    notifyListeners();
  }
}
