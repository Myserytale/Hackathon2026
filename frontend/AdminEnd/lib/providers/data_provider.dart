import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../models/application.dart';
import '../models/audit_entry.dart';

class DataProvider extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:8080/api';
  
  List<Application> _applications = [];
  List<AuditEntry> _auditLogs = [];
  bool _isLoading = false;
  String? _authToken;

  List<Application> get applications => _applications;
  List<AuditEntry> get auditLogs => _auditLogs;
  bool get isLoading => _isLoading;

  void updateToken(String? token) {
    _authToken = token;
    if (token != null) {
      loadInitialData();
    }
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch Applications
      final appResponse = await http.get(Uri.parse('$baseUrl/funding'), headers: _headers);
      if (appResponse.statusCode == 200) {
        final List<dynamic> data = jsonDecode(appResponse.body);
        _applications = data.map((item) => _mapToApplication(item)).toList();
      }

      // Fetch Audit Logs (simulated or if backend has it)
      // Note: If backend doesn't have an audit endpoint yet, we keep mock logs for demo
      _auditLogs = _getMockAuditLogs();

    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> approveApplication(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/funding/$id/status'),
        headers: _headers,
        body: 'APPROVED', // Backend expects a plain string body for status
      );

      if (response.statusCode == 200) {
        await loadInitialData(); // Refresh list
      }
    } catch (e) {
      debugPrint('Error approving application: $e');
    }
  }

  Future<void> rejectApplication(String id, String reason) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/funding/$id/status'),
        headers: _headers,
        body: 'REJECTED',
      );

      if (response.statusCode == 200) {
        await loadInitialData();
      }
    } catch (e) {
      debugPrint('Error rejecting application: $e');
    }
  }

  Application _mapToApplication(Map<String, dynamic> json) {
    return Application(
      id: json['id'].toString(),
      farmerName: json['farmerName'] ?? 'Fermier Necunoscut',
      farmLocation: json['location'] ?? 'Nespecificat',
      bovineCount: json['animalCount'] ?? 0,
      requestedAmount: (json['requestedAmount'] as num?)?.toDouble() ?? 0.0,
      submissionDate: json['submissionDate'] != null 
          ? DateTime.parse(json['submissionDate']) 
          : DateTime.now(),
      status: _mapStatus(json['status']),
      documents: (json['documents'] as List<dynamic>?)
          ?.map((d) => d['fileName'].toString())
          .toList() ?? [],
    );
  }

  ApplicationStatus _mapStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVED': return ApplicationStatus.approved;
      case 'REJECTED': return ApplicationStatus.rejected;
      case 'PENDING': return ApplicationStatus.pending;
      default: return ApplicationStatus.pending;
    }
  }

  List<AuditEntry> _getMockAuditLogs() {
    // Keep mock logs if backend doesn't provide them yet, 
    // but enrich them with real actions if needed
    final now = DateTime.now();
    return [
      _createAuditEntry('1', 'Sistem Online', 'System', now, 'Backend conectat cu succes via Spring Boot'),
      _createAuditEntry('2', 'Data Sync', 'Admin', now.subtract(const Duration(minutes: 5)), 'Preluare date în timp real din baza de date'),
    ];
  }

  AuditEntry _createAuditEntry(String id, String action, String actor, DateTime ts, String details) {
    final raw = '$id$action$actor$ts$details';
    final hash = sha256.convert(utf8.encode(raw)).toString();
    return AuditEntry(
      id: id,
      action: action,
      actor: actor,
      timestamp: ts,
      hash: hash,
      details: details,
    );
  }
}
