import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/application.dart';
import '../models/audit_entry.dart';

class MockDataService {
  static List<Application> getMockApplications() {
    return [
      Application(
        id: 'APP-001',
        farmerName: 'Ion Popescu',
        farmLocation: 'Cluj-Napoca, CJ',
        bovineCount: 45,
        requestedAmount: 12500.0,
        submissionDate: DateTime.now().subtract(const Duration(days: 2)),
        status: ApplicationStatus.pending,
      ),
      Application(
        id: 'APP-002',
        farmerName: 'Elena Dumitru',
        farmLocation: 'Huedin, CJ',
        bovineCount: 22,
        requestedAmount: 6200.0,
        submissionDate: DateTime.now().subtract(const Duration(days: 1)),
        status: ApplicationStatus.pending,
      ),
      Application(
        id: 'APP-003',
        farmerName: 'Gheorghe Muresan',
        farmLocation: 'Turda, CJ',
        bovineCount: 110,
        requestedAmount: 30000.0,
        submissionDate: DateTime.now().subtract(const Duration(hours: 5)),
        status: ApplicationStatus.pending,
      ),
    ];
  }

  static List<AuditEntry> getMockAuditLogs() {
    final now = DateTime.now();
    return [
      _createAuditEntry(
        '1',
        'Approved Funding APP-452',
        'Admin Maria',
        now.subtract(const Duration(minutes: 15)),
        'Approved €12,500 for Farmer Sandu',
      ),
      _createAuditEntry(
        '2',
        'Issued Crotalia #12345',
        'Vet Valeriu',
        now.subtract(const Duration(hours: 2)),
        'Verified health status for Bovine #12345',
      ),
      _createAuditEntry(
        '3',
        'Rejected Application APP-410',
        'Admin Maria',
        now.subtract(const Duration(hours: 4)),
        'Missing veterinary certification',
      ),
    ];
  }

  static AuditEntry _createAuditEntry(
    String id,
    String action,
    String actor,
    DateTime ts,
    String details,
  ) {
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
