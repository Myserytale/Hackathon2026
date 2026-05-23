class Animal {
  final int? id;
  final String tagNumber;
  final String species;
  final String? breed;
  final DateTime? birthDate;
  final String healthStatus;
  final int? ownerId;

  Animal({
    this.id,
    required this.tagNumber,
    required this.species,
    this.breed,
    this.birthDate,
    required this.healthStatus,
    this.ownerId,
  });

  int get age {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int calculatedAge = now.year - birthDate!.year;
    if (now.month < birthDate!.month || (now.month == birthDate!.month && now.day < birthDate!.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagNumber': tagNumber,
      'species': species,
      'breed': breed,
      'birthDate': birthDate?.toIso8601String(),
      'healthStatus': healthStatus,
      'ownerId': ownerId,
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'] is String ? int.tryParse(map['id']) : map['id'],
      tagNumber: map['tagNumber'] ?? '',
      species: map['species'] ?? '',
      breed: map['breed'],
      birthDate: map['birthDate'] != null ? DateTime.tryParse(map['birthDate']) : null,
      healthStatus: map['healthStatus'] ?? 'Healthy',
      ownerId: map['ownerId'] is String ? int.tryParse(map['ownerId']) : map['ownerId'],
    );
  }
}

