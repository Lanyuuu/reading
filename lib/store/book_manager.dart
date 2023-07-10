/*
 * @Author: LiZhi
 * @Date: 2023-07-10 23:29:07
 * @Description: 图书数据库管理
 * @Import: import 'store/book_manager.dart';
 */
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import '../model/book_model.dart';

class DatabaseManager {
  static Database? _database;

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
          '''
          CREATE TABLE books (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            author TEXT,
            coverUrl TEXT,
            additionalInfo TEXT
          )
          '''
        );
      },
    );
  }

  // 添加图书
  static Future<void> addBook(Book book) async {
    final db = await database;
    await db.insert('books', book.toMap());
  }

  // 获取所有图书
  static Future<List<Book>> getAllBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');
    return List.generate(maps.length, (index) {
      return Book.fromMap(maps[index]);
    });
  }

  // 更新图书
  static Future<void> updateBook(Book book) async {
    final db = await database;
    await db.update('books', book.toMap(), where: 'id = ?', whereArgs: [book.id]);
  }

  // 删除图书
  static Future<void> deleteBook(int id) async {
    final db = await database;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }
}
