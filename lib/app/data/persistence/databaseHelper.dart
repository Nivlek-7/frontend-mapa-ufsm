import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/local.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'favorites.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites(
            id INT PRIMARY KEY,
            nome TEXT,
            lat REAL,
            longi REAL,
            rotulos TEXT,
            rotulos2 TEXT,
            sigla TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertFavorite(Local local) async {
    final db = await database;
    await db.insert(
      'favorites',
      local.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertFavorites(List<Local> locais) async {
    final db = await database;
    Batch batch = db.batch();

    for (Local local in locais) {
      batch.insert(
        'favorites',
        local.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Local>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) {
      return Local.fromMap(maps[i]);
    });
  }

  Future<void> deleteFavorite(String id) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('favorites');
  }
}
