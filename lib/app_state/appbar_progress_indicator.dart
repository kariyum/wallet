import 'package:flutter/material.dart';

class AppbarProgressIndicator extends ChangeNotifier {
  bool _loading = false;
  AppbarProgressIndicator();

  bool get loading => _loading;

  bool get isLoading => _loading == true;

  void start() {
    _loading = true;
    notifyListeners();
  }

  void stop() {
    _loading = false;
    notifyListeners();
  }
}
