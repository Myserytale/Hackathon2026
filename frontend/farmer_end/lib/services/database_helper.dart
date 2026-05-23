import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    String path = join(await getDatabasesPath(), 'farm_management.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE animals (
        id TEXT PRIMARY KEY,
        name TEXT,
        species TEXT,
        age INTEGER,
        weight REAL,
        healthStatus TEXT
      )
    ''');
    
    // Seed with initial data if needed
    await db.insert('animals', {
      'id': '1', 'name': 'Bessie', 'species': 'Cow', 'age': 5, 'weight': 600.0, 'healthStatus': 'Healthy'
    });
    await db.insert('animals', {
      'id': '2', 'name': 'Clucky', 'species': 'Chicken', 'age': 1, 'weight': 2.5, 'healthStatus': 'Healthy'
    });
  }
}
