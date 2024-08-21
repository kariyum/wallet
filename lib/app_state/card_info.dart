import 'package:flutter/material.dart';

class CardInfoModel extends ChangeNotifier {

  bool _showCardInfo = true;
  bool _showCurrentBalance = true;

  CardInfoModel(
    this._showCardInfo,
    this._showCurrentBalance,
  );

  bool get showCardInfo => _showCardInfo;
  bool get showCurrentBalance => _showCurrentBalance;

  void switchShowCardInfo() {
    _showCardInfo = !_showCardInfo;
    notifyListeners();
  }

  void switchShowCurrentBalance() {
     _showCurrentBalance = !_showCurrentBalance;
     notifyListeners();
  }
}
