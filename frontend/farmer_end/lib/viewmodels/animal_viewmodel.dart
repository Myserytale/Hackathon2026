import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/animal_service.dart';

class AnimalViewModel extends ChangeNotifier {
  final AnimalService _animalService = AnimalService();
  List<Animal> _animals = [];
  bool _isLoading = false;

  List<Animal> get animals => _animals;
  bool get isLoading => _isLoading;

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
      _animals = await _animalService.fetchAnimals();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAnimal(Animal animal) async {
    await _animalService.addAnimal(animal);
    await loadAnimals(); // Refresh list
  }

  Future<void> removeAnimal(String id) async {
    await _animalService.removeAnimal(id);
    await loadAnimals(); // Refresh list
  }
}
