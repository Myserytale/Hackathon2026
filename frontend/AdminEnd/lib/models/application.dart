enum ApplicationStatus { pending, approved, rejected, needsFix }

class Application {
  final String id;
  final String farmerName;
  final String farmLocation;
  final int bovineCount;
  final double requestedAmount;
  final DateTime submissionDate;
  final ApplicationStatus status;
  final List<String> documents;

  Application({
    required this.id,
    required this.farmerName,
    required this.farmLocation,
    required this.bovineCount,
    required this.requestedAmount,
    required this.submissionDate,
    required this.status,
    required this.documents,
  });
}
