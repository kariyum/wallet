import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:walletapp/services/database.dart';

import '../models/item.dart';

class ItemsModel extends ChangeNotifier {
  Map<DateTime, List<Item>> _itemsByDate = {};
  Map<(int, int), List<Item>> _itemsByMonth = {};
  List<Item> itemsArg;
  bool initialized = false;

  ItemsModel({required this.itemsArg});

  static Future<ItemsModel> create() async {
    debugPrint("calling ItemsModel constructor");
    final items = await fetchItems();
    debugPrint("FETCHED ITEMS ARE ${items.length}");
    return ItemsModel(itemsArg: items);
  }

  UnmodifiableListView<Item> get items {
    if (!initialized && itemsArg.isEmpty) _updateItems();
    return UnmodifiableListView(itemsArg);
  }

  UnmodifiableMapView<DateTime, List<Item>> get itemsByDate {
    if (!initialized && itemsArg.isEmpty) _updateItems();
    if (_itemsByDate.isEmpty) {
      _itemsByDate = itemsArg.groupedByDay();
      return UnmodifiableMapView(_itemsByDate);
    }
    return UnmodifiableMapView(_itemsByDate);
  }

  UnmodifiableMapView<(int, int), List<Item>> get itemsByMonth {
    if (!initialized && (itemsArg.isEmpty || _itemsByDate.isEmpty)) _updateItems();
    if (_itemsByMonth.isEmpty) {
      _itemsByMonth = _itemsByDate.flatten().groupedByMonth();
      return UnmodifiableMapView(_itemsByMonth);
    }
    return UnmodifiableMapView(_itemsByMonth);
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
        db.insert('items', item.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> _updateItems() async {
    if (!initialized) {
      initialized = true;
      List<Item> items = await fetchItems();
      debugPrint("Updating items with ${items.length}");
      itemsArg = items;
      _itemsByDate = itemsArg.groupedByDay();
      _itemsByMonth = _itemsByDate.flatten().groupedByMonth();
      notifyListeners();
    }
  }

  void add(Item item) {
    insertItem(item: item).then((_) async {
      List<Item> items = await fetchItems();
      debugPrint("Updating items with ${items.length}");
      itemsArg = items;
      _itemsByDate = itemsArg.groupedByDay();
      _itemsByMonth = _itemsByDate.flatten().groupedByMonth();
      notifyListeners();
    }).catchError((_) => (), test: (error) {
      debugPrint("insert item failed: $error");
      return false;
    });
  }

  void set(List<Item> items) {
    itemsArg = items;
    _itemsByDate = itemsArg.groupedByDay();
    _itemsByMonth = _itemsByDate.flatten().groupedByMonth();
    notifyListeners();
  }

  void removeItem(Item item) {
    debugPrint("Items before deletion ${itemsArg.length}");
    itemsArg.remove(item);
    debugPrint("Items after deletion ${itemsArg.length}");
    _itemsByDate = itemsArg.groupedByDay();
    _itemsByMonth = _itemsByDate.flatten().groupedByMonth();
    notifyListeners();
  }

  Future<void> switchPaid(int id) {
    final int index = itemsArg.indexWhere((item) => item.id! == id);
    if (index != -1) {
      final res = itemsArg.elementAt(index).itemSwitchPaid();
      final paid = itemsArg.elementAt(index).paid == 1 ? 0 : 1;
      itemsArg.elementAt(index).paid = paid;
      _itemsByDate = itemsArg.groupedByDay();
      _itemsByMonth = _itemsByDate.flatten().groupedByMonth();
      notifyListeners();
      return res;
    }
    return Future.value();
  }

  void updateItem(Item item) {
    item.persist().catchError((_) => (), test: (error) {
      debugPrint("insert item failed: $error");
      return false;
    });
    final int index = itemsArg.indexWhere((itemA) => itemA.id! == item.id!);
    if (index != -1) {
      itemsArg[index] = Item.fromJson(item.toMap());
      _itemsByDate = itemsArg.groupedByDay();
      _itemsByMonth = _itemsByDate.flatten().groupedByMonth();
      notifyListeners();
    }
  }
}
