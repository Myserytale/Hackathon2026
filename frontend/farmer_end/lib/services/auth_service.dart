import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:8080/api/auth';

  final Map<String, String> _localUsers = {};
  String? _mockOtpCode;
  String? _mockTempUser;

  bool _isAuthenticated = false;
  String? _token;
  String? _tempToken;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get tempToken => _tempToken;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get mockOtpCode => _mockOtpCode;

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    if (username == 'test_farmer' || username == 'fermier_ion') {
      _isLoading = false;
      _errorMessage = 'Username already exists';
      notifyListeners();
      return false;
    }

    if (_localUsers.containsKey(username)) {
      _isLoading = false;
      _errorMessage = 'Username already exists';
      notifyListeners();
      return false;
    }

    _localUsers[username] = password;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_localUsers.containsKey(username)) {
      await Future.delayed(const Duration(milliseconds: 500));
      _isLoading = false;
      if (_localUsers[username] == password) {
        _tempToken = 'mock-temp-token-$username';
        _mockTempUser = username;
        final code = (100000 + (username.hashCode.abs() % 900000)).toString();
        _mockOtpCode = code;
        
        debugPrint('\n====== MOCK ROeID NOTIFICATION (FRONTEND MOCK) ======');
        debugPrint('To: $username');
        debugPrint('Your ROeID authentication code is: $code');
        debugPrint('=====================================================\n');
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid credentials';
        notifyListeners();
        return false;
      }
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      _isLoading = false;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _tempToken = data['token'];
        _mockTempUser = null;
        _mockOtpCode = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.body;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Connection error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String code) async {
    if (_tempToken == null) {
      _errorMessage = 'Missing temporary 2FA token';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_mockTempUser != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      _isLoading = false;
      if (_mockOtpCode == code) {
        _token = 'mock-jwt-token-$_mockTempUser';
        _isAuthenticated = true;
        _tempToken = null;
        _mockOtpCode = null;
        _mockTempUser = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid 2FA code';
        notifyListeners();
        return false;
      }
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-2fa'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tempToken': _tempToken, 'code': code}),
      );

      _isLoading = false;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _isAuthenticated = true;
        _tempToken = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.body;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Connection error: $e';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _token = null;
    _tempToken = null;
    _mockOtpCode = null;
    _mockTempUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
