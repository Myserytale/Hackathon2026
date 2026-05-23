import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = 'farm_management.db';
    if (!kIsWeb) {
      path = join(await getDatabasesPath(), path);
    }
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS animals');
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE animals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagNumber TEXT UNIQUE,
        species TEXT,
        name TEXT,
        type TEXT,
        breed TEXT,
        birthDate TEXT,
        healthStatus TEXT,
        ownerId INTEGER
      )
    ''');
    
    // Seed with demo data matching the backend DataSeeder
    final demoAnimals = [
      {
        'tagNumber': 'RO-10001',
        'species': 'Cow',
        'name': 'Bessie',
        'type': 'COW',
        'breed': 'Holstein',
        'birthDate': '2021-05-23T00:00:00.000',
        'healthStatus': 'Healthy',
        'ownerId': 1,
      },
      {
        'tagNumber': 'RO-10002',
        'species': 'Cow',
        'name': 'Milka',
        'type': 'COW',
        'breed': 'Angus',
        'birthDate': '2023-03-15T00:00:00.000',
        'healthStatus': 'Healthy',
        'ownerId': 1,
      },
      {
        'tagNumber': 'RO-10003',
        'species': 'Pig',
        'name': 'Porky',
        'type': 'PIG',
        'breed': 'Mangalica',
        'birthDate': '2024-11-01T00:00:00.000',
        'healthStatus': 'Healthy',
        'ownerId': 1,
      },
      {
        'tagNumber': 'RO-10004',
        'species': 'Sheep',
        'name': 'Fluffy',
        'type': 'SHEEP',
        'breed': 'Merinos',
        'birthDate': '2022-08-10T00:00:00.000',
        'healthStatus': 'Healthy',
        'ownerId': 1,
      },
      {
        'tagNumber': 'RO-10005',
        'species': 'Chicken',
        'name': 'Clucky',
        'type': 'CHICKEN',
        'breed': 'Rhode Island Red',
        'birthDate': '2025-01-20T00:00:00.000',
        'healthStatus': 'Healthy',
        'ownerId': 1,
      },
    ];
    
    for (final animal in demoAnimals) {
      await db.insert('animals', animal);
    }
  }
}
