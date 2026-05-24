enum AlertStatus { pending, validated, rejected }

class Alert {
  final String id;
  final String dossierId;
  final String farmerName;
  final String animalType;
  final String animalTag;
  final String description;
  final String? farmerDocumentUrl;
  final DateTime timestamp;
  final AlertStatus status;

  Alert({
    required this.id,
    required this.dossierId,
    required this.farmerName,
    required this.animalType,
    required this.animalTag,
    required this.description,
    this.farmerDocumentUrl,
    required this.timestamp,
    this.status = AlertStatus.pending,
  });
}
