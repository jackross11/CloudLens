import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'favorites.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imageUrl TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertFavorite(String imageUrl) async {
    final db = await database;
    return await db.insert('favorites', {'imageUrl': imageUrl});
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.query('favorites');
  }

  static Future<int> deleteFavorite(String imageUrl) async {
    final db = await database;
    return await db.delete('favorites', where: 'imageUrl = ?', whereArgs: [imageUrl]);
  }
}
