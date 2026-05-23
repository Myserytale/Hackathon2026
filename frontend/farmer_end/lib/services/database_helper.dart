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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
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
        breed TEXT,
        birthDate TEXT,
        healthStatus TEXT,
        ownerId INTEGER
      )
    ''');
    
    // Seed with initial data if needed
    await db.insert('animals', {
      'tagNumber': 'RO-10001',
      'species': 'Cow',
      'breed': 'Holstein',
      'birthDate': '2021-05-23T00:00:00.000',
      'healthStatus': 'Healthy',
      'ownerId': 1,
    });
    await db.insert('animals', {
      'tagNumber': 'RO-10002',
      'species': 'Pig',
      'breed': 'Landrace',
      'birthDate': '2025-05-23T00:00:00.000',
      'healthStatus': 'Healthy',
      'ownerId': 1,
    });
  }
}
