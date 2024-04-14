import 'dart:math';

import 'package:walletapp/services/database.dart';

class Item {
  final int? id;
  final String title;
  final double price;
  final int timestamp;
  final int? day;
  final int? hour;
  final int? minute;
  final int? month;
  final int? year;
  final String? notes;
  final int? paid;

  const Item({
    this.id,
    this.day,
    this.hour,
    this.minute,
    this.month,
    this.year,
    this.notes,
    this.paid,
    required this.title,
    required this.price,
    required this.timestamp,
  });

  factory Item.fromJson(Map<String, dynamic> map) {
    DateTime d =
        DateTime.fromMillisecondsSinceEpoch(map['timestamp']).toLocal();
    return Item(
      id: map['id'],
      price: map['price'],
      timestamp: map['timestamp'],
      title: map['title'],
      notes: map['notes'],
      day: d.day,
      month: d.month,
      hour: d.hour,
      minute: d.minute,
      paid: map['paid'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title[0].toUpperCase() + title.substring(1),
      'price': price,
      'timestamp': timestamp,
      "notes": notes,
      "paid": paid
    };
  }

  @override
  String toString() {
    return 'Item(id: $id, title: $title, price: $price, day: $day, month: $month, hour: $hour, minute: $minute, notes: $notes, paid: $paid)';
  }

  Future<void> persist() async {
    await DatabaseRepository.instance.insertItem(item: this);
  }

  bool isCredit() {
    return price < 0;
  }

  static const List<String> months = <String>[ 'Jan.', 'Feb.', 'March', 'Apr.', 'May', 'June', 'July', 'Aug.', 'Sept.', 'Oct.', 'Nov.', 'Dec.' ];
  static const List<String> days = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String note() {
    String s = '';
    switch (day) {
      case 1:
        s = 'st';
        break;
      case 2:
        s = 'nd';
        break;
      case 3:
        s = 'rd';
        break;
      default:
        s = 'th';
    }

    return '${months[month! - 1]} ${day.toString()}$s';
  }

  Future<void> delete(id) async {
    await DatabaseRepository.instance.deleteItem(id);
  }

  Future<void> itemSwitchPaid(isPaid) async {
    await DatabaseRepository.instance.itemSwitchPaid(id: id!, isPaid: isPaid);
  }

  String formatDate() {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final weekDay = days.elementAt(date.weekday - 1);
    final month = months.elementAt(date.month - 1);
    return "$weekDay, $month ${date.day}";
  }
}

extension Transactions on List<Item> {
  double minPurshase() {
    return where((item) => item.price < 0).fold(
        0,
        (previousValue, item) =>
            previousValue > item.price ? previousValue : item.price);
  }

  double availableBalance() {
    return fold(0, (acc, item) => acc + item.price);
  }

  double totalCredit() {
    return where((item) => item.price < 0)
        .fold(0, (previousValue, element) => previousValue + element.price);
  }

  double totalDebit() {
    return where((item) => item.price > 0)
        .fold(0, (previousValue, item) => previousValue + item.price);
  }

  Map<DateTime, List<Item>> groupedByDay() {
    // h(DateTime date) => "${date.}"
    f(date) => "${date.year} - ${date.month} - ${date.day}";
    g(str) => DateTime.parse(str);
    DateTime reset(int timestamp) {
      final remainder = timestamp % 86400000;
      return DateTime.fromMillisecondsSinceEpoch(timestamp - remainder);
    }
    final remainder = DateTime.now().millisecondsSinceEpoch % 86400000;
    print("Remainder is $remainder");
    print(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch - remainder).toIso8601String());
    return fold(
        {},
        (map, item) => map
          ..putIfAbsent(
              reset(item.timestamp),
              () => <Item>[]).add(item));
  }

  Map<(int, int), List<Item>> groupedByMonth() {
    Map<(int, int), List<Item>> result = <(int, int), List<Item>>{};
    for (final item in this) {
      final date = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
      final key = (date.year, date.month);
      result.putIfAbsent(key, () => <Item>[]).add(item);
    }
    return result;
  }

  Map<String, List<Item>> groupedByCategory() {
    Map<String, List<Item>> result = <String, List<Item>>{};
    for (final item in this) {
      result.putIfAbsent(item.title, () => <Item>[]).add(item);
    }
    return result;
  }
}
// class YearMonth{
//   final int year;
//   final int month;
//   const YearMonth(this.year, this.month);
// }
extension ExpenseFormatting on double {
  String format() {
    String stringDigit = abs().toStringAsFixed(3);
    String precision =
        stringDigit.split("").reversed.take(4).toList().reversed.join();
    List<String> chunks = [];
    for (int i = 4; i < (stringDigit.length); i += 3) {
      chunks.add(stringDigit
          .split("")
          .reversed
          .join()
          .substring(i, min(i + 3, stringDigit.length))
          .split("")
          .reversed
          .join());
    }
    String sign = this < 0 ? "- " : "";
    String pre = precision == ".000" ? "" : precision;
    return sign + chunks.reversed.join(" ") + pre;
  }
}

extension Statistics on Map<DateTime, List<Item>> {
  List<Item> flatten() {
    return values.fold(<Item>[], (previousValue, element) => previousValue + element);
  }
}