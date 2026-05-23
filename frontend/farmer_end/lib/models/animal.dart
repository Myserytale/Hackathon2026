class Animal {
  final String id;
  final String name;
  final String species;
  final int age;
  final double weight;
  final String healthStatus;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.age,
    required this.weight,
    required this.healthStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'age': age,
      'weight': weight,
      'healthStatus': healthStatus,
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'],
      name: map['name'],
      species: map['species'],
      age: map['age'],
      weight: map['weight'],
      healthStatus: map['healthStatus'],
    );
  }
}
