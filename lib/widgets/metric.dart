import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walletapp/app_state/items_model.dart';
import 'package:walletapp/models/item.dart';

import '../app_state/config.dart';

class Metric extends StatelessWidget {
  final String metric;
  final double value;

  const Metric({super.key, required this.metric, required this.value});

  @override
  Widget build(BuildContext context) {
    return Consumer<Config>(
      builder: (BuildContext context, Config config, Widget? child) => Column(
        children: [
          ListTile(
            visualDensity: VisualDensity.compact,
            dense: true,
            title: Text(
              metric,
              style: TextStyle(fontSize: 16),
            ),
            trailing: Text(
              "${value.format()} ${config.currencyToString(config.currency)}",
              style: TextStyle(
                fontSize: 16,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       metric,
          //       style: TextStyle(fontSize: 16),
          //     ),
          //     Text(
          //       "${value.format()} ${config.currencyToString(config.currency)}",
          //       style: TextStyle(
          //         fontSize: 16,
          //         // fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
    return Card(
      margin: EdgeInsets.all(4.0),
      child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Consumer<Config>(
            builder: (BuildContext context, Config config, Widget? child) {
              return FittedBox(
                child: Row(
                  children: [
                    Text(
                      metric,
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "${value.format()} ${config.currencyToString(config.currency)}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
              // return Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Align(
              //       // alignment: Alignment.centerRight,
              //       child: Text(
              //         "${value.format()} ${config.currencyToString(config.currency)}",
              //         style: TextStyle(
              //           fontSize: 24,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //     Align(
              //       // alignment: Alignment.centerRight,
              //       child: Text(
              //         metric,
              //         style: TextStyle(
              //           fontSize: 16
              //         ),
              //       ),
              //     ),
              //   ],
              // );
            },
          )),
    );
  }
}
