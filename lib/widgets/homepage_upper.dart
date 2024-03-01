import 'package:flutter/material.dart';
import 'package:walletapp/services/database.dart';
import 'package:walletapp/models/item.dart';
import 'package:flutter/scheduler.dart';
import 'package:walletapp/widgets/homepage_upper.dart';
import 'package:walletapp/widgets/item_input_dialog.dart';
import 'dart:ui';

class HomePageFirstHalf extends StatefulWidget {
  final List<Item> items;
  const HomePageFirstHalf({super.key, required this.items});

  @override
  State<HomePageFirstHalf> createState() => _HomePageFirstHalfState();
}

class _HomePageFirstHalfState extends State<HomePageFirstHalf> {
  @override
  Widget build(BuildContext context) {
    List<Item> items = widget.items;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    String formatCurrency(double currency) {
      return "${((currency * 100).toInt() / 100).toString().padLeft(8, ' ')}  ";
    }
    
    String totalExpensesFromDate(List<Item> items, DateTime from, DateTime to) {
      final Iterable<double> filteredItems = items.where((item) {
        DateTime itemsDate = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
        DateTime date = DateTime(itemsDate.year, itemsDate.month, itemsDate.day);
        debugPrint(date.toString());
        return !date.isBefore(from) && !date.isAfter(to);
      }).map((item) => item.price);
      double amount = filteredItems.isEmpty
          ? 0
          : filteredItems
              .fold(0, (previousValue, element) => previousValue + element);
      // amount = (amount * 100).toInt()/100;
      // return amount.toString().padLeft(8, ' ');
      return formatCurrency(amount);
    }

    final credits = items.where((item) => item.isCredit()).toList();
    final debits = items.where((item) => !item.isCredit()).toList();
    final config = <String, (String, String)>{
      "Today": (
        totalExpensesFromDate(debits, today, today),
        totalExpensesFromDate(credits, today, today)
      ),
      "Yesturday": (
        totalExpensesFromDate(
            debits, 
            today.subtract(const Duration(days: 1)),
            today.subtract(const Duration(days: 1))),
        totalExpensesFromDate(
            credits, 
            today.subtract(const Duration(days: 1)), 
            today.subtract(const Duration(days: 1)),)
      ),
      "Last 7 days": (
        totalExpensesFromDate(
            debits,
            today.subtract(Duration(days: today.weekday - 1)),
            today.add(Duration(days: 7 - today.weekday))),
        totalExpensesFromDate(
            credits,
            today.subtract(Duration(days: today.weekday - 1)),
            today.add(Duration(days: 7 - today.weekday)))
      ),
      "${today.month}": (
        totalExpensesFromDate(
          debits, 
          DateTime(today.year, today.month), 
          today.add(Duration(days: 30))),
        totalExpensesFromDate(
          credits, 
          DateTime(today.year, today.month), 
          today.add(Duration(days: 30)))
          )
    };
    final configMap = Map.from(config);
    
    double totalPrice = items
        .map((e) => e.price)
        .fold(0, (previousValue, element) => previousValue + element);
    
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.all(8.0),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Good Morning,",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(100, 100, 100, 1),
                ),
              ),
              Text(
                "Today's Summary",
                style: TextStyle(
                  fontSize: 24,
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Balance",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    // "${totalPrice.padLeft(8)} DT",
                    formatCurrency(totalPrice),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.start,
                  )
                ],
              ),
              const Divider(
                height: 9,
              ),
              Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...config.entries.map<Widget>((entry) {
                          var metric = entry.key;
                          var debit = entry.value.$1;
                          var credit = entry.value.$2;
                          return Text(
                            metric,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.left,
                          );
                        }).toList()
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ...config.entries.map<Widget>((entry) {
                          var metric = entry.key;
                          var debit = entry.value.$1;
                          var credit = entry.value.$2;
                          return Text(
                            debit.trim() != "0.0" ? debit : '',
                            style: const TextStyle(
                              fontSize: 18,
                              color:Color.fromARGB(255, 15, 157, 88),
                            ),
                          );
                        }).toList()
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ...config.entries.map<Widget>((entry) {
                          var metric = entry.key;
                          var debit = entry.value.$1;
                          var credit = entry.value.$2;
                          return Text(
                            credit,
                            style: const TextStyle(
                              fontSize: 18,
                              color:Color.fromARGB(255, 219, 68, 55),
                            ),
                          );
                        }).toList()
                      ],
                    ),
                  ),
                ],
              ),
              // ...config.entries.map<Widget>((entry) {
              //   var metric = entry.key;
              //   var debit = entry.value.$1;
              //   var credit = entry.value.$2;
              //   return Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(
              //         metric,
              //         style: TextStyle(
              //           fontSize: 18,
              //         ),
              //       ),
              //       Row(
              //         children: [
              //           if (debit.trim() != '0')
              //             Text(
              //               debit,
              //               style: TextStyle(
              //                 fontSize: 18,
              //                 color: Color.fromARGB(255, 21, 128, 64),
              //               ),
              //             ),
              //           Padding(padding: EdgeInsets.fromLTRB(15, 0, 15, 0)),
              //           Text(
              //             credit,
              //             style: TextStyle(
              //               fontSize: 18,
              //             ),
              //           ),
              //         ],
              //       )
              //     ],
              //   );
              // }).toList(),
            ],
          ),
        )
      ],
    );
  }
}
