import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/alert.dart';
import '../models/audit_entry.dart';

class DataService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:8080/api';
  
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
      final response = await http.get(Uri.parse('$baseUrl/grant-dossiers/status/PENDING_VET'), headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _alerts = data.map((item) => _mapToAlert(item)).toList();
      } else {
        _alerts = [];
      }
      
      // Fetch audit logs if available
      final auditResponse = await http.get(Uri.parse('$baseUrl/audit'), headers: _headers);
      if (auditResponse.statusCode == 200) {
        final List<dynamic> auditData = jsonDecode(auditResponse.body);
        // Map to audit entries...
      }

    } catch (e) {
      debugPrint('Error loading vet data: $e');
      _alerts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Alert> get pendingAlerts => _alerts.where((a) => a.status == AlertStatus.pending).toList();
  List<AuditEntry> get auditTrail => _auditTrail.reversed.toList();

  Future<void> validateAlert(String dossierId, String signatureBase64) async {
    final index = _alerts.indexWhere((a) => a.dossierId == dossierId);
    if (index != -1) {
      final alert = _alerts[index];
      
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/grant-dossiers/$dossierId/vet-review'),
          headers: _headers,
          body: jsonEncode({
            'action': 'APPROVE',
            'veterinarianId': 2, // Hardcoded for demo if not using real auth
            'signatureBase64': signatureBase64,
          }),
        );
        
        if (response.statusCode == 200) {
          _alerts[index] = Alert(
            id: alert.id,
            dossierId: alert.dossierId,
            farmerName: alert.farmerName,
            animalType: alert.animalType,
            animalTag: alert.animalTag,
            description: alert.description,
            farmerDocumentUrl: alert.farmerDocumentUrl,
            timestamp: alert.timestamp,
            status: AlertStatus.validated,
          );
          
          final newId = "A${_auditTrail.length + 1}";
          final rawData = "$newId${alert.id}${DateTime.now().toIso8601String()}";
          final hash = sha256.convert(utf8.encode(rawData)).toString();
          
          _auditTrail.add(AuditEntry(
            id: newId,
            action: "Aprobare Dosar Grant SCZ: ${alert.animalTag}",
            timestamp: DateTime.now(),
            entityId: "RO-${100000 + _auditTrail.length}",
            hash: hash,
          ));
          
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error validating alert: $e');
      }
    }
  }

  Future<void> rejectAlert(String dossierId) async {
    final index = _alerts.indexWhere((a) => a.dossierId == dossierId);
    if (index != -1) {
      final alert = _alerts[index];
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/grant-dossiers/$dossierId/vet-review'),
          headers: _headers,
          body: jsonEncode({
            'action': 'REJECT',
            'veterinarianId': 2,
          }),
        );
        if (response.statusCode == 200) {
          _alerts[index] = Alert(
            id: alert.id,
            dossierId: alert.dossierId,
            farmerName: alert.farmerName,
            animalType: alert.animalType,
            animalTag: alert.animalTag,
            description: alert.description,
            farmerDocumentUrl: alert.farmerDocumentUrl,
            timestamp: alert.timestamp,
            status: AlertStatus.rejected,
          );
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error rejecting alert: $e');
      }
    }
  }

  Alert _mapToAlert(Map<String, dynamic> json) {
    return Alert(
      id: json['id'].toString(),
      dossierId: json['id'].toString(),
      farmerName: json['farmer'] != null ? json['farmer']['username'] : "Fermier Necunoscut",
      animalType: "Cerere Grant SCZ (Vițel Nou-născut)",
      animalTag: json['animal'] != null ? json['animal']['tagNumber'] : "N/A",
      description: "Dosar de Grant pentru animalul ${json['animal'] != null ? json['animal']['tagNumber'] : 'N/A'}",
      farmerDocumentUrl: json['farmerDocumentUrl'],
      timestamp: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      status: _mapStatus(json['status']),
    );
  }

  AlertStatus _mapStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING_APIA': return AlertStatus.validated;
      case 'RETURNED_TO_FARMER': return AlertStatus.rejected;
      default: return AlertStatus.pending;
    }
  }
}
