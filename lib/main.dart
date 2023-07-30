import 'package:flutter/material.dart';
import 'package:walletapp/screens/home.dart';

// import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet',
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 8, 116, 178)),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      home: const MyHomePage(),
    );
  }
}