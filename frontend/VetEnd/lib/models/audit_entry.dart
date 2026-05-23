class AuditEntry {
  final String id;
  final String action;
  final DateTime timestamp;
  final String hash;
  final String entityId;

  AuditEntry({
    required this.id,
    required this.action,
    required this.timestamp,
    required this.hash,
    required this.entityId,
  });
}
