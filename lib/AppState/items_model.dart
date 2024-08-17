import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:walletapp/services/database.dart';

import '../models/item.dart';

class ItemsModel extends ChangeNotifier {
  List<Item> _items = [];
  Map<DateTime, List<Item>> _itemsByDate = {};
  List<Item> itemsArg;
  ItemsModel({required this.itemsArg});

  static Future<ItemsModel> create() async {
    debugPrint("calling ItemsModel constructor");
    final items = await fetchItems();
    debugPrint("FETCHED ITEMS ARE ${items.length}");
    return ItemsModel(itemsArg: items);
  }

  UnmodifiableListView<Item> get items {
    debugPrint("${_items.length}");
    debugPrint("GETTING ITEMS FROM PROVIDER");
    return UnmodifiableListView(itemsArg);
  }

  UnmodifiableMapView<DateTime, List<Item>> get itemsByDate {
    if (_itemsByDate.isEmpty) return UnmodifiableMapView(itemsArg.groupedByDay());
    return UnmodifiableMapView(_itemsByDate);
  }

  static Future<List<Item>> fetchItems() {
    final stopwatch = Stopwatch()..start();
    return DatabaseRepository.instance.database.then((Database db) async {
      final result = await db.query('items', orderBy: 'timestamp DESC');
      stopwatch.stop();
      final milliseconds = stopwatch.elapsedMilliseconds;
      debugPrint('# Future took $milliseconds milliseconds to complete.');
      // print(result.map((json) => Item.fromJson(json)).toList());
      return result.map((json) => Item.fromJson(json)).toList();
    }).catchError((_) => <Item>[], test: (error) {
      debugPrint("_fetchItems error $error");
      return true;
    });
  }

  Future<void> insertItem({required Item item}) async {
    return DatabaseRepository.instance.database.then((Database db) {
      if (item.id == null) {
        db.insert('items', item.toMap());
      } else {
        db.insert('items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> _updateItems() async {
    List<Item> items = await fetchItems();
    _items = items;
  }

  void add(Item item) {
    insertItem(item: item).catchError((_) => (), test: (error) {
      debugPrint("insert item failed: $error");
      return false;
    });
    _items.add(item);
    notifyListeners();
  }

  void set(List<Item> items) {
    _items = items;
    notifyListeners();
  }

  void removeItem(Item item) {
    _items.remove(item);
    notifyListeners();
  }
}
