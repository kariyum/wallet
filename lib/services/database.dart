import 'dart:async';
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
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  FutureOr<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await db.execute('''ALTER TABLE items ADD notes TEXT''');
    await db.execute('''ALTER TABLE items ADD paid INTEGER''');
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT, 
      price REAL,
      notes TEXT,
      timestamp INTEGER,
      paid INTEGER
    ) ''');

    await db.execute('''CREATE TABLE users (
      pin TEXT PRIMARY KEY
    ) ''');
  }

  Future<void> insertItem({required Item item}) async {
    try {
      final db = await instance.database;
      // print("Inserting item $item");
      if (item.id == null) {
        await db.insert('items', item.toMap());
      } else {
        await db.update('items', item.toMapUpdate(), where: 'id = ?', whereArgs: [item.id]);
      }
      // print('inserted');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> itemSwitchPaid({required int id, required int isPaid}) async {
    try {
      final db = await instance.database;
      // print("Inserting item $item");
      await db.update('items', {"paid": isPaid},
          where: 'id = ?', whereArgs: [id]);
      // print('');
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
    final stopwatch = Stopwatch()..start();
    print("started at ");
    final db = await instance.database;

    final result = await db.query('items', orderBy: 'timestamp DESC');

    stopwatch.stop();
    final milliseconds = stopwatch.elapsedMilliseconds;

    print('Future took $milliseconds milliseconds to complete.');

    // print(result.map((json) => Item.fromJson(json)).toList());
    return result.map((json) => Item.fromJson(json)).toList();
  }

  Future<void> deleteDB() async {
    // final items = await getAllItems();

    // final dbPath = await getDatabasesPath();
    // final path = p.join(dbPath, 'wallet.db');
    // await databaseFactory.deleteDatabase(path);
    // await _initDB("wallet.db");

    // deleteDatabase('wallet.db');
  }
}
