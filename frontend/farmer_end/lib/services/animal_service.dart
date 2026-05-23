import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import '../models/animal.dart';
import 'database_helper.dart';

class AnimalService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  static const String baseUrl = 'http://localhost:8080/api/animals';

  bool _isMockToken(String? token) {
    return token == null || token.startsWith('mock-');
  }

  Future<List<Animal>> fetchAnimals(String? token) async {
    if (_isMockToken(token)) {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('animals');
      
      return List.generate(maps.length, (i) {
        return Animal.fromMap(maps[i]);
      });
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Animal.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load animals from backend: ${response.body}');
    }
  }

  Future<void> addAnimal(Animal animal, String? token) async {
    if (_isMockToken(token)) {
      final db = await _dbHelper.database;
      await db.insert(
        'animals',
        animal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return;
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(animal.toMap()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add animal to backend: ${response.body}');
    }
  }

  Future<void> removeAnimal(int id, String? token) async {
    if (_isMockToken(token)) {
      final db = await _dbHelper.database;
      await db.delete(
        'animals',
        where: 'id = ?',
        whereArgs: [id],
      );
      return;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete animal from backend: ${response.body}');
    }
  }
}
