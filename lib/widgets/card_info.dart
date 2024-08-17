import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walletapp/models/item.dart';

import '../AppState/items_model.dart';

class CardInfo extends StatefulWidget {
  const CardInfo({super.key});

  @override
  State<CardInfo> createState() => _CardInfoState();
}

class _CardInfoState extends State<CardInfo> {
  bool showCurrentBalance = true;
  bool showCardInfo = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.all(8),
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<ItemsModel>(
                builder: (context, itemsModel, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TapRegion(
                          onTapInside: (event) {
                            setState(() {
                              showCurrentBalance = !showCurrentBalance;
                            });
                            return;
                          },
                          // child: AnimatedCount(count: items.availableBalance()),
                          child: Text(
                            () {
                              if (showCardInfo && showCurrentBalance) {
                                return "${itemsModel.items.availableBalance().format()} DNT";
                              }
                              if (showCardInfo && !showCurrentBalance) {
                                return "${itemsModel.items.forecastedExpenses().format()} DNT";
                              }
                              return "---";
                            }(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TapRegion(
                          onTapInside: (event) {
                            setState(() {
                              showCardInfo = !showCardInfo;
                            });
                            return;
                          },
                          child: showCardInfo
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                        )
                      ],
                    ),
                    if (showCurrentBalance)
                      const Text(
                        "Available Balance",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      )
                    else
                      const Text(
                        "Forecasted Balance",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    const Divider(),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.red[100],
                          maxRadius: 16,
                          child: Icon(
                            Icons.arrow_downward_rounded,
                            color: Colors.red[600],
                          ),
                        ),
                        const VerticalDivider(),
                        Text(
                          showCardInfo
                              ? "${itemsModel.items.totalCredit().format()} DNT"
                              : "---",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green[100],
                          maxRadius: 16,
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.green[600],
                          ),
                        ),
                        const VerticalDivider(),
                        Text(
                          showCardInfo
                              ? "${itemsModel.items.totalDebit().format()} DNT"
                              : "---",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // AnimatedPositioned(
        //   child: Container(
        //       decoration: BoxDecoration(
        //           // color: Color.fromARGB(200, 255, 255, 255),
        //           borderRadius: new BorderRadius.all(
        //               Radius.elliptical(10, 10))),
        //     child: Padding(
        //       padding: EdgeInsets.all(8.0),
        //       child: ClipRect(
        //         child: BackdropFilter(
        //           filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        //           child: Text("+ 1000", style: TextStyle(
        //             color: Colors.green,
        //             fontSize: 24,
        //             fontWeight: FontWeight.bold,
        //           ),),
        //         ),
        //       ),
        //     ),
        //   ),
        //   top: 100,
        //   left: 15,
        //   duration: Duration(milliseconds: 300),
        //   curve: Curves.easeOut,
        // )
      ],
    );
  }
}
