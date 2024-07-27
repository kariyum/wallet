import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:walletapp/models/item.dart';

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
    if (kIsWeb) {
      final factory = databaseFactoryFfiWeb;
      // final dbPath = await getDatabasesPath();
      // final path = p.join(dbPath, filePath);
      final db = await factory.openDatabase("test.db", options: OpenDatabaseOptions(
          version: 2,
          onCreate: _createDB,
          onUpgrade: _upgradeDB
      ));
      debugPrint("$db");
      return db;
    } else
      // if (Platform.isAndroid) {
    //   final dbPath = await getDatabasesPath();
    //   final path = p.join(dbPath, filePath);
    //   return await openDatabase(
    //     path,
    //     version: 2,
    //     onCreate: _createDB,
    //     onUpgrade: _upgradeDB,
    //   );
    // } else
     {
      throw Exception("DB IS NOT INITIALIZED");
    }
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
        await db.insert('items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
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
    final db = await instance.database;

    final result = await db.query('items', orderBy: 'timestamp DESC');

    stopwatch.stop();
    final milliseconds = stopwatch.elapsedMilliseconds;

    print('Future took $milliseconds milliseconds to complete.');

    // print(result.map((json) => Item.fromJson(json)).toList());
    return result.map((json) => Item.fromJson(json)).toList();
  }

  Future<void> saveAllItems(List<Item> items) {
    List<Future<void>> futures = [];
    for (var item in items) {
      futures.add(item.persist());
    }
    return Future.wait(futures);
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
