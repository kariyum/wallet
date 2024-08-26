import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletapp/services/lock_screen.dart';

enum Currency {
  tnd,
  euro,
  dollars,
}

class Config extends ChangeNotifier {
  bool _hasLockScreen = true;
  Currency _currency = Currency.tnd;
  Color get creditColor => Color.fromARGB(255, 219, 68, 55);
  Color get debitColor => Color.fromARGB(255, 15, 157, 88);
  Color get iconColor => Color.fromARGB(255, 66, 133, 244);

  Future<SharedPreferences> sharedPreferencesInstance =
      SharedPreferences.getInstance();

  Config();

  Future init() async {
    SharedPreferences instance = await sharedPreferencesInstance;
    debugPrint("hasLockScreen ${instance.getBool("hasLockScreen")}");
    bool? hasLockScreen = instance.getBool("hasLockScreen");
    if (hasLockScreen != null) {
      _hasLockScreen = hasLockScreen;
    }
    debugPrint("CONFIG hasLockScreen = $hasLockScreen");
    final String? currency = instance.getString("currency");
    if (currency != null) {
      _currency = stringToCurrency(currency);
    }
    debugPrint("Currency ${currency}");
  }

  Currency get currency => _currency;

  bool get hasLockScreen => _hasLockScreen;


  void setCurrency(Currency currency) async {
    _currency = currency;
    SharedPreferences instance = await sharedPreferencesInstance;
    instance.setString("currency", currency.name);
    notifyListeners();
  }

  String currencyToString(Currency currency) {
    switch (currency) {
      case Currency.tnd:
        return "DNT";
      case Currency.euro:
        return "€";
      case Currency.dollars:
        return "\$";
    }
  }

  Currency stringToCurrency(String curr) {
    return Currency.values
        .where((currency) => currency.name == curr)
        .firstOrNull!;
  }

  Future setLockscreen(bool value) async {
    debugPrint("setLockScreen($value)");
    _hasLockScreen = value;
    final instance = await sharedPreferencesInstance;
    if (value == false) {
      debugPrint("Deleting pin");
      deletePin();
    }

    final future = instance.setBool("hasLockScreen", value);
    future.whenComplete(() => notifyListeners());
    return future;
  }
}
