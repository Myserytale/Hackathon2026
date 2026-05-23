enum AlertStatus { pending, validated, rejected }

class Alert {
  final String id;
  final String farmerName;
  final String animalType;
  final String description;
  final DateTime timestamp;
  final AlertStatus status;

  Alert({
    required this.id,
    required this.farmerName,
    required this.animalType,
    required this.description,
    required this.timestamp,
    this.status = AlertStatus.pending,
  });
}
