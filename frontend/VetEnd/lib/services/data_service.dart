import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/alert.dart';
import '../models/audit_entry.dart';

class DataService extends ChangeNotifier {
  static String get baseUrl => ApiConfig.apiBaseUrl;
  
  List<Alert> _alerts = [];
  final List<AuditEntry> _auditTrail = [];
  String? _authToken;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void updateToken(String? token) {
    _authToken = token;
    if (token != null) {
      loadData();
    }
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // For Vet Portal, "Alerts" can be mapped to Incidents or just mock for demo
      // but let's try to fetch incidents from backend
      final response = await http.get(Uri.parse('$baseUrl/incidents'), headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _alerts = data.map((item) => _mapToAlert(item)).toList();
      } else {
        // Fallback to mock if endpoint doesn't exist yet
        _alerts = _getMockAlerts();
      }
      
      // Fetch audit logs if available
      final auditResponse = await http.get(Uri.parse('$baseUrl/audit'), headers: _headers);
      if (auditResponse.statusCode == 200) {
        final List<dynamic> auditData = jsonDecode(auditResponse.body);
        // Map to audit entries...
      }

    } catch (e) {
      debugPrint('Error loading vet data: $e');
      _alerts = _getMockAlerts();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Alert> get pendingAlerts => _alerts.where((a) => a.status == AlertStatus.pending).toList();
  List<AuditEntry> get auditTrail => _auditTrail.reversed.toList();

  Future<void> validateAlert(String alertId) async {
    // In a real integration, we might create a Consultation or update Incident status
    // For demo, we'll simulate the backend call and update local state
    
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      final alert = _alerts[index];
      
      try {
        // Mock a backend call to "process" this alert
        await Future.delayed(const Duration(milliseconds: 500));
        
        _alerts[index] = Alert(
          id: alert.id,
          farmerName: alert.farmerName,
          animalType: alert.animalType,
          description: alert.description,
          timestamp: alert.timestamp,
          status: AlertStatus.validated,
        );
        
        // Add to audit trail (simulating blockchain/ledger record)
        final newId = "A${_auditTrail.length + 1}";
        final rawData = "$newId${alert.id}${DateTime.now().toIso8601String()}";
        final hash = sha256.convert(utf8.encode(rawData)).toString();
        
        _auditTrail.add(AuditEntry(
          id: newId,
          action: "Validare: ${alert.animalType}",
          timestamp: DateTime.now(),
          entityId: "RO-${100000 + _auditTrail.length}",
          hash: hash,
        ));
        
        notifyListeners();
      } catch (e) {
        debugPrint('Error validating alert: $e');
      }
    }
  }

  void rejectAlert(String alertId) {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      final alert = _alerts[index];
      _alerts[index] = Alert(
        id: alert.id,
        farmerName: alert.farmerName,
        animalType: alert.animalType,
        description: alert.description,
        timestamp: alert.timestamp,
        status: AlertStatus.rejected,
      );
      notifyListeners();
    }
  }

  Alert _mapToAlert(Map<String, dynamic> json) {
    return Alert(
      id: json['id'].toString(),
      farmerName: "Fermier ID: ${json['farmerId']}",
      animalType: json['type'] ?? 'Animal',
      description: json['description'] ?? 'Fără descriere',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      status: _mapStatus(json['status']),
    );
  }

  AlertStatus _mapStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'VALIDATED': return AlertStatus.validated;
      case 'REJECTED': return AlertStatus.rejected;
      default: return AlertStatus.pending;
    }
  }

  List<Alert> _getMockAlerts() {
    return [
      Alert(
        id: "1",
        farmerName: "Fermier Sandu",
        animalType: "Vițel (Nou-născut)",
        description: "Raportat naștere vițel la ferma din satul Bontida.",
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Alert(
        id: "2",
        farmerName: "Maria Popescu",
        animalType: "Ovine",
        description: "Transfer de 10 ovine către abatorul autorizat local.",
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }
}
