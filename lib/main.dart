import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:walletapp/screens/home.dart';
import 'package:walletapp/screens/lock_screen.dart';

// import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet',
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 8, 116, 178),
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      home: const LockScreen(),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Wallet',
//       darkTheme: ThemeData.dark(),
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color.fromARGB(255, 8, 116, 178),
//         ),
//         useMaterial3: true,
//       ),
//       themeMode: ThemeMode.light,
//       home: const MyHomePage(),
//     );
//   }
// }