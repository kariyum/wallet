import 'package:walletapp/services/database.dart';

Future<String?> getUserPin() async {
  final db = await DatabaseRepository.instance.database;
  final result = await db.query('users');
  return result.map((json) => json['pin'].toString()).toList().firstOrNull;
}

Future<bool> skippedLoginScreen(int value) async {
  final userPin = await getUserPin();
  if (userPin == "-1") {
    return true;
  }
  return false;
}

Future<int> insertPin(String pin) async {
  // await deletePin();
  final db = await DatabaseRepository.instance.database;
  return db.insert('users', {'pin': pin});
}

Future<void> deletePin() async {
  final db = await DatabaseRepository.instance.database;
  await db.delete('users');
}