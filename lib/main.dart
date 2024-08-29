import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletapp/app_state/theme_provider.dart';
import 'package:walletapp/firebase_options.dart';
import 'package:walletapp/screens/home.dart';
import 'package:walletapp/screens/lock_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:walletapp/services/lock_screen.dart';

import 'app_state/appbar_progress_indicator.dart';
import 'app_state/card_info.dart';
import 'app_state/config.dart';
import 'app_state/items_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final initFirebaseFuture = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final stopwatch = Stopwatch()..start();

  final initNotificationsFuture = AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    null,
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        // channelShowBadge: true,
        onlyAlertOnce: true,
        playSound: true,
        criticalAlerts: true,
      )
    ],
    // Channel groups are only visual and are not required
    channelGroups: [
      NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic group')
    ],
  );
  final pinFuture = getUserPin();
  final themeProvider = ThemeProvider();

  final config = Config();

  await config.init();
  await initNotificationsFuture;
  await initFirebaseFuture;
  await themeProvider.init();

  final pin = await pinFuture;

  stopwatch.stop();
  debugPrint("Initialization took ${stopwatch.elapsedMilliseconds}ms");
  runApp(
    ChangeNotifierProvider(
      create: (context) => themeProvider,
      builder: (context, child) => MyApp(
        pin: pin,
        config: config,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String? pin;
  final Config config;

  const MyApp({
    super.key,
    this.pin,
    required this.config,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        debugPrint("themeMode ${themeProvider.themeMode}");
        return MaterialApp(
            title: 'Wallet',
            darkTheme: themeProvider.darkTheme,
            theme: themeProvider.themeData,
            themeMode: themeProvider.themeMode,
            home: ChangeNotifierProvider(
              builder: (context, child) => screen(context, widget.config),
              create: (BuildContext context) => widget.config,
            ));
      },
    );
  }

  Widget screen(BuildContext context, Config config) {
    debugPrint("MAIN widget.pin == ${widget.pin}");
    if (config.hasLockScreen) {
      return LockScreen(pin: widget.pin);
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ItemsModel(itemsArg: [])),
        ChangeNotifierProvider(create: (context) => CardInfoModel(true, true)),
        ChangeNotifierProvider(create: (context) => AppbarProgressIndicator()),
      ],
      builder: (context, child) => const MyHomePage(),
    );
  }
}
