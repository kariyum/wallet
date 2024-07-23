import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

import '../models/item.dart';

class Firebase {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> uploadItems(List<Item> items) async {
    final itemsCollection = firestore.collection("items");
    final data = {
      "items": items.map((item) => item.toMap()),
      "id": DateTime.now().microsecondsSinceEpoch.toString(),
    };
    final persistFuture = itemsCollection.add(data);
    return persistFuture.then((value) {
      print(value);
      return value.id;
    });
  }

  Future<List<Item>> downloadItems(String id) {
    final itemsCollection = firestore.collection("items");
    final data = itemsCollection
        .doc(id)
        .get()
        .then((doc) => doc.data()?["items"])
        .then((object) {
      final List<Item> items = (object as List<dynamic>).map((obj) {
        return Item.fromJson(obj);
      }).toList();

      return items;
    });
    return data;
  }
}
