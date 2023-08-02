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

  const Item({
    this.id,
    this.day,
    this.hour,
    this.minute,
    this.month,
    this.year,
    required this.title,
    required this.price,
    required this.timestamp,
  });

  factory Item.fromJson(Map<String, dynamic> map) {
    DateTime d =
        DateTime.fromMillisecondsSinceEpoch(map['timestamp']).toLocal();
    // print(Item(
    //   id: map['id'],
    //   price: map['price'],
    //   timestamp: map['timestamp'],
    //   title: map['title'],
    //   day: d.day,
    //   hour: d.hour,
    //   minute: d.minute,
    //   month: d.month,
    //   year: d.year,
    // ).toString());
    return Item(
      id: map['id'],
      price: map['price'],
      timestamp: map['timestamp'],
      title: map['title'],
      day: d.day,
      month: d.month,
      hour: d.hour,
      minute: d.minute,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title[0].toUpperCase() + title.substring(1), 'price': price, 'timestamp': timestamp};
  }

  @override
  String toString() {
    return 'Item(id: $id, title: $title, price: $price, day: $day, month: $month, hour: $hour, minute: $minute)';
  }

  Future<void> persist() async {
    await DatabaseRepository.instance.insertItem(item: this);
  }

  bool isCredit() {
    return price < 0;
  }

  String note() {
    List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    String s = '';
    switch (month) {
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
}