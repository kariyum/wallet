import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier  {
  ThemeData _themeData = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color.fromRGBO(9, 29, 51, 1.0),
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
      brightness: Brightness.light,
    ),
  );

  ThemeData _darkTheme = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color.fromRGBO(9, 29, 51, 1.0),
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
      brightness: Brightness.dark,
    ),
  );

  ThemeMode _themeMode = ThemeMode.system;
  late SharedPreferences instance;

  Future init() async {
    instance = await SharedPreferences.getInstance();
    final mode = instance.getString("themeMode");
    switch (mode) {
      case "dark":
        _themeMode = ThemeMode.dark;

      case "light":
        _themeMode = ThemeMode.light;

      case "system":
        _themeMode = ThemeMode.system;
    }
  }

  Future setDarkTheme() async {
    await instance.setString("themeMode", "dark");
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  Future setLightTheme() async {
    await instance.setString("themeMode", "light");
    _themeMode = ThemeMode.light;
    notifyListeners();
  }

  Future setSystemTheme() async {
    await instance.setString("themeMode", "system");
    _themeMode = ThemeMode.system;
    notifyListeners();
  }

  bool isDarkMode() {
    if (_themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  bool isLightMode() {
    if (_themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.light;
    }
    return _themeMode == ThemeMode.light;
  }

  ThemeMode get themeMode => _themeMode;
  ThemeData get themeData => _themeData;
  ThemeData get darkTheme => _darkTheme;
}
