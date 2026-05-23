import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../models/animal.dart';
import 'database_helper.dart';

class AnimalService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Mock data for web fallback
  final List<Animal> _webMockAnimals = [];

  Future<List<Animal>> fetchAnimals() async {
    if (kIsWeb) return List.from(_webMockAnimals);
    
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('animals');
    
    return List.generate(maps.length, (i) {
      return Animal.fromMap(maps[i]);
    });
  }

  Future<void> addAnimal(Animal animal) async {
    final db = await _dbHelper.database;
    await db.insert(
      'animals',
      animal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeAnimal(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'animals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
