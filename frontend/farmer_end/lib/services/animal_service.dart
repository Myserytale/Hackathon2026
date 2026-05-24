import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/animal.dart';
import 'database_helper.dart';
import 'auth_service.dart';
import 'package:sqflite/sqflite.dart';
import '../config/api_config.dart';

class AnimalService {
  static String get baseUrl => '${ApiConfig.apiBaseUrl}/animals';
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  String? _authToken;

  void updateToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<List<Animal>> fetchAnimals() async {
    // Try backend API first
    if (_authToken != null) {
      try {
        final response = await http.get(
          Uri.parse(baseUrl),
          headers: _headers,
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((item) => Animal.fromMap(item)).toList();
        }
      } catch (e) {
        debugPrint('Backend unavailable, falling back to local DB: $e');
      }
    }
    
    // Fallback to local SQLite
    if (kIsWeb) return _getLocalDemoData();
    
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('animals');
    return List.generate(maps.length, (i) => Animal.fromMap(maps[i]));
  }

  Future<void> addAnimal(Animal animal) async {
    // Try backend API first
    if (_authToken != null) {
      try {
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: _headers,
          body: jsonEncode(animal.toMap()),
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          return; // Successfully added to backend
        }
        debugPrint('Backend add animal failed: ${response.statusCode} ${response.body}');
      } catch (e) {
        debugPrint('Backend unavailable for add, saving locally: $e');
      }
    }
    
    // Fallback to local SQLite
    if (!kIsWeb) {
      final db = await _dbHelper.database;
      await db.insert(
        'animals',
        animal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> removeAnimal(int id) async {
    // Try backend API first
    if (_authToken != null) {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/$id'),
          headers: _headers,
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200 || response.statusCode == 204) {
          return;
        }
        debugPrint('Backend delete animal failed: ${response.statusCode} ${response.body}');
      } catch (e) {
        debugPrint('Backend unavailable for delete, removing locally: $e');
      }
    }
    
    // Fallback to local SQLite
    if (!kIsWeb) {
      final db = await _dbHelper.database;
      await db.delete('animals', where: 'id = ?', whereArgs: [id]);
    }
  }

  List<Animal> _getLocalDemoData() {
    return [
      Animal(
        id: 1,
        tagNumber: 'RO-10001',
        species: 'Cow',
        name: 'Bessie',
        breed: 'Holstein',
        birthDate: DateTime(2021, 5, 23),
        healthStatus: 'Healthy',
        ownerId: 1,
      ),
      Animal(
        id: 2,
        tagNumber: 'RO-10002',
        species: 'Cow',
        name: 'Milka',
        breed: 'Angus',
        birthDate: DateTime(2023, 3, 15),
        healthStatus: 'Healthy',
        ownerId: 1,
      ),
      Animal(
        id: 3,
        tagNumber: 'RO-10003',
        species: 'Pig',
        name: 'Porky',
        breed: 'Mangalica',
        birthDate: DateTime(2024, 11, 1),
        healthStatus: 'Healthy',
        ownerId: 1,
      ),
      Animal(
        id: 4,
        tagNumber: 'RO-10004',
        species: 'Sheep',
        name: 'Fluffy',
        breed: 'Merinos',
        birthDate: DateTime(2022, 8, 10),
        healthStatus: 'Sick',
        ownerId: 1,
      ),
    ];
  }
}
