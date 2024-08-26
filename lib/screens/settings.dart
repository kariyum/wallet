import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:walletapp/widgets/notification_settings.dart';

import '../app_state/config.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _idController = TextEditingController();

  bool _lock_screen = true;
  final WidgetStateProperty<Icon?> thumbIcon =
      WidgetStateProperty.resolveWith<Icon?>(
    (Set<WidgetState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<Config>(
      builder: (context, config, child) {
        return Column(
          children: [
            ListTile(
              title: Text("Currency"),
              leading: Icon(Icons.wallet),
              trailing: Text(
                config.currencyToString(config.currency),
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                await onCurrencyTap(config);
              },
            ),
            ListTile(
              title: Text("Notifications"),
              leading: Icon(Icons.notifications),
              onTap: () async {
                showGeneralDialog(
                  barrierDismissible: true,
                  barrierLabel: "QUIT",
                  context: context,
                  pageBuilder: (ctx, a, b) => Dialog.fullscreen(
                    child: NotificationSettings(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Lock screen"),
              leading: Icon(Icons.lock),
              trailing: Switch(
                thumbIcon: thumbIcon,
                value: config.hasLockScreen,
                onChanged: (value) {
                  config.setLockscreen(value);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Currency?> onCurrencyTap(Config config) {
    const List<Currency> supportedCurrencies = Currency.values;
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final currency in supportedCurrencies)
                    ListTile(
                      title: Center(
                          child: Text(config.currencyToString(currency))),
                      visualDensity: const VisualDensity(
                          vertical: VisualDensity.minimumDensity),
                      onTap: () {
                        config.setCurrency(currency);
                        Navigator.of(context).pop();
                      },
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
    ;
  }
}
