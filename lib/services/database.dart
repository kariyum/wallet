import 'package:walletapp/models/item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseRepository {
  static final DatabaseRepository instance = DatabaseRepository._init();
  DatabaseRepository._init();

  Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wallet.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // await deleteDatabase("wallet.db");
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT, 
      price REAL, 
      timestamp INTEGER
    ) ''');

    await db.execute('''CREATE TABLE users (
      pin TEXT PRIMARY KEY
    ) ''');
  }

  Future<void> insertItem({required Item item}) async {
    try {
      final db = await instance.database;
      await db.insert('items', item.toMap());
      // print('inserted');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> insertPin({required String pin}) async {
    try {
      final db = await instance.database;
      await db.insert('users', {'pin': pin});
      print('inserted');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deletePin() async {
    try {
      final db = await instance.database;
      await db.delete('users');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      final db = await instance.database;
      await db.delete(
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<String>> readPin() async {
    final db = await instance.database;

    final result = await db.query('users');

    return result.map((json) => json['pin'].toString()).toList();
  }

  Future<List<Item>> getAllItems() async {
    final db = await instance.database;

    final result = await db.query('items');

    return result.map((json) => Item.fromJson(json)).toList();
  }

  Future<void> deleteDB() async {
    // final dbPath = await getDatabasesPath();
    // final path = p.join(dbPath, 'wallet.db');
    // databaseFactory.deleteDatabase(path);
    deleteDatabase('wallet.db');
  }
}
