class AuditEntry {
  final String id;
  final String action;
  final String actor;
  final DateTime timestamp;
  final String hash;
  final String details;

  AuditEntry({
    required this.id,
    required this.action,
    required this.actor,
    required this.timestamp,
    required this.hash,
    required this.details,
  });
}
