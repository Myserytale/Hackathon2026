enum ApplicationStatus { pending, approved, rejected, needsFix }

class Application {
  final String id;
  final String farmerName;
  final String farmLocation;
  final int bovineCount;
  final double requestedAmount;
  final DateTime submissionDate;
  final ApplicationStatus status;
  final String? farmerDocumentUrl;
  final String? vetDocumentUrl;
  final String animalTag;

  Application({
    required this.id,
    required this.farmerName,
    required this.farmLocation,
    required this.bovineCount,
    required this.requestedAmount,
    required this.submissionDate,
    required this.status,
    this.farmerDocumentUrl,
    this.vetDocumentUrl,
    required this.animalTag,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    ApplicationStatus parsedStatus = ApplicationStatus.needsFix;
    String rawStatus = json['status'] ?? '';
    if (rawStatus == 'PENDING_APIA') parsedStatus = ApplicationStatus.pending;
    if (rawStatus == 'APPROVED') parsedStatus = ApplicationStatus.approved;
    if (rawStatus == 'RETURNED_TO_VET' || rawStatus == 'RETURNED_TO_FARMER') parsedStatus = ApplicationStatus.rejected;

    return Application(
      id: json['id'].toString(),
      farmerName: json['farmer']?['username'] ?? 'Fermier Necunoscut',
      farmLocation: json['farmer']?['location'] ?? 'Locație Necunoscută',
      bovineCount: 1,
      requestedAmount: 400.0,
      submissionDate: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      status: parsedStatus,
      farmerDocumentUrl: json['farmerDocumentUrl'],
      vetDocumentUrl: json['vetDocumentUrl'],
      animalTag: json['animal']?['tagNumber'] ?? 'N/A',
    );
  }
}
