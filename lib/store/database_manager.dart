import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class DatabaseManager {
  static Database? _database; // 将变量声明为可空类型

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE my_table (id INTEGER PRIMARY KEY, name TEXT)',
        );
      },
    );
  }

  static Future<List<Map<String, dynamic>>> fetchData() async {
    final db = await database;

    return await db.query('my_table');
  }

  static Future<int> insertData(String name) async {
    final db = await database;

    final row = {'name': name};
    return await db.insert('my_table', row);
  }

  static Future<int> updateData(int id, String newName) async {
    final db = await database;

    final row = {'name': newName};
    return await db.update('my_table', row, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteData(int id) async {
    final db = await database;

    return await db.delete('my_table', where: 'id = ?', whereArgs: [id]);
  }
}
