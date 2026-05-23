import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  static const String baseUrl = 'https://localhost/api/auth';

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

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      _isLoading = false;
      if (response.statusCode == 200) {
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

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

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
    _errorMessage = null;
    notifyListeners();
  }
}
