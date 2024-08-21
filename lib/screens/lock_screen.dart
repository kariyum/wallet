import 'package:flutter/material.dart';
import 'package:walletapp/app_state/card_info.dart';
import 'package:walletapp/screens/home.dart';
import 'package:walletapp/services/lock_screen.dart';

import 'package:provider/provider.dart';

import '../app_state/items_model.dart';
import '../models/item.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isLocked = false;
  String? _pin;

  @override
  void initState() {
    super.initState();
    // final pin = getUserPin();
    // if (pin != null) {
    //   _isLocked = pin.isEmpty || (pin.isNotEmpty && pin != "-1");
    //   _pin = pin;
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocked) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ItemsModel(itemsArg: [])),
          ChangeNotifierProvider(create: (context) => CardInfoModel(true, true)),
        ],
        child: const MyHomePage(),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Text("Welcome"),
          const Text("Enter your PIN please"),
          Center(
            child: SizedBox(
              width: 300,
              child: TextFormField(
                onFieldSubmitted: (value) async {
                  debugPrint(value);
                  final savedPin = await getUserPin();
                  if (value != savedPin) {
                    debugPrint("wrong PIN");
                  }
                  if (savedPin == null) {
                    await insertPin(value);
                    setState(() {
                      _isLocked = false;
                    });
                  }
                  if (savedPin == value) {
                    setState(() {
                      _isLocked = false;
                    });
                  }
                },
                textAlign: TextAlign.center,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 22,
                ),
                decoration: const InputDecoration(
                  hintText: 'PIN',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          )
        ],
      ),
    );
  }
}
