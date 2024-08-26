import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:walletapp/app_state/appbar_progress_indicator.dart';
import 'package:walletapp/app_state/card_info.dart';
import 'package:walletapp/screens/home.dart';
import 'package:walletapp/services/lock_screen.dart';

import 'package:provider/provider.dart';

import '../app_state/config.dart';
import '../app_state/items_model.dart';
import '../models/item.dart';

class LockScreen extends StatefulWidget {
  final String? pin;

  const LockScreen({super.key, required this.pin});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with WidgetsBindingObserver  {
  bool _isLocked = true;

  final focusNode = FocusNode();
  String? _errorString;
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    focusNode.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      focusNode.unfocus();
      focusNode.requestFocus();
    }
  }

  String? validate(value) {
    if (value == null) {
      return "Input a pin please!";
    }
    if (value.trim().isEmpty) {
      return "Input a pin please";
    }
    if (value != widget.pin && widget.pin != null) {
      return "Wrong pin!";
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();
    if (!_isLocked) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ItemsModel(itemsArg: [])),
          ChangeNotifierProvider(
              create: (context) => CardInfoModel(true, true)),
          ChangeNotifierProvider(
              create: (context) => AppbarProgressIndicator()),
        ],
        builder: (context, child) => const MyHomePage(),
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
              child: TextField(
                focusNode: focusNode,
                onSubmitted: (value) {
                  final bool validInput = validate(value) == null;
                  setState(() {
                    _errorString = validate(value);
                  });
                  final savedPin = widget.pin;
                  if (savedPin == null && validInput) {
                    insertPin(value).then((_) {
                      setState(() {
                        _isLocked = false;
                        config.setLockscreen(true);
                      });
                    });
                  } else {
                    debugPrint("PIN IS $savedPin");
                    if (savedPin == value && validInput) {
                      setState(() {
                        _isLocked = false;
                        config.setLockscreen(true);
                      });
                    }
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
                decoration: InputDecoration(
                  hintText: 'PIN',
                  errorText: _errorString,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          if (widget.pin == null)
            Expanded(
              child: SafeArea(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                      onPressed: () async {
                        await config.setLockscreen(false);
                        setState(() {
                          _isLocked = false;
                        });
                      },
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ),
              ),
            )
        ],
      ),
    );
  }
}
