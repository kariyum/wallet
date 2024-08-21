import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walletapp/models/item.dart';

import '../app_state/card_info.dart';
import '../app_state/items_model.dart';
import 'animated_count.dart';

class CardInfo extends StatelessWidget {
  const CardInfo({
    super.key,
  });

  double getBalance(CardInfoModel cardInfoModel, ItemsModel itemsModel) {
    if (cardInfoModel.showCurrentBalance) {
      return itemsModel.items.availableBalance();
    }
    return itemsModel.items.forecastedExpenses();
  }

  void onToggleTotalExpenses(CardInfoModel cardInfoModel) {
    cardInfoModel.switchShowCurrentBalance();
  }

  void onToggleVisibility(CardInfoModel cardInfoModel) {
    cardInfoModel.switchShowCardInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer2<ItemsModel, CardInfoModel>(
              builder: (context, itemsModel, cardInfoModel, child) {
                final items = itemsModel.items;
                final dailyAverageExpense = items.averageExpense();
                final dailyAverageIncome = items.averageIncome();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TapRegion(
                          onTapInside: (PointerDownEvent event) =>
                              onToggleTotalExpenses(cardInfoModel),
                          child: () {
                            if (!cardInfoModel.showCardInfo) {
                              return const Text(
                                "---",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                            return AnimatedCount(
                                count: getBalance(cardInfoModel, itemsModel));
                          }(),
                        ),
                        TapRegion(
                          onTapInside: (event) =>
                              onToggleVisibility(cardInfoModel),
                          child: cardInfoModel.showCardInfo
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                        )
                      ],
                    ),
                    if (cardInfoModel.showCurrentBalance)
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
                          cardInfoModel.showCardInfo
                              ? "${dailyAverageExpense.format()} DNT"
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
                          cardInfoModel.showCardInfo
                              ? "${dailyAverageIncome.format()} DNT"
                              : "---",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
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
