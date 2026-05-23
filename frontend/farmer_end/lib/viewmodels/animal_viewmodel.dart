import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/animal_service.dart';
import '../services/auth_service.dart';

class AnimalViewModel extends ChangeNotifier {
  final AnimalService _animalService = AnimalService();
  List<Animal> _animals = [];
  bool _isLoading = false;
  String? _authToken;

  List<Animal> get animals => _animals;
  bool get isLoading => _isLoading;

  void updateAuth(AuthService authService) {
    _authToken = authService.token;
    if (authService.isAuthenticated) {
      loadAnimals();
    } else {
      _animals = [];
      notifyListeners();
    }
  }

  Map<String, List<Animal>> get categorizedAnimals {
    final Map<String, List<Animal>> categorized = {};
    for (var animal in _animals) {
      if (!categorized.containsKey(animal.species)) {
        categorized[animal.species] = [];
      }
      categorized[animal.species]!.add(animal);
    }
    return categorized;
  }

  List<String> get speciesList => categorizedAnimals.keys.toList()..sort();

  Future<void> loadAnimals() async {
    _isLoading = true;
    notifyListeners();
    try {
      _animals = await _animalService.fetchAnimals(_authToken);
    } catch (e) {
      debugPrint('Error loading animals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAnimal(Animal animal) async {
    try {
      await _animalService.addAnimal(animal, _authToken);
      await loadAnimals(); // Refresh list
    } catch (e) {
      debugPrint('Error adding animal: $e');
    }
  }

  Future<void> removeAnimal(int id) async {
    try {
      await _animalService.removeAnimal(id, _authToken);
      await loadAnimals(); // Refresh list
    } catch (e) {
      debugPrint('Error removing animal: $e');
    }
  }
}
