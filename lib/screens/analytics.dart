import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walletapp/app_state/items_model.dart';
import 'package:walletapp/models/item.dart';
import 'package:walletapp/services/utils.dart';
import 'package:walletapp/widgets/metric.dart';

import '../app_state/config.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({
    super.key,
  });

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  Map<(int, int), List<Item>> itemsByMonth = {};

  @override
  Widget build(BuildContext context) {
    final topWidget = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Consumer<ItemsModel>(
            builder: (BuildContext context, ItemsModel itemsModel, Widget? child) {
              return Column(
                children: [
                  Metric(metric: "Daily", value: itemsModel.itemsByDate.dailyAverageExpense()),
                  Metric(metric: "Monthly", value: itemsModel.items.monthlyAverageExpenses()),
                ],
              );
            }
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8),
        child: Text(
          "Monthly expenses",
          style: TextStyle(
            fontSize: 21,
          ),
        ),
      ),
    ];
    return Consumer2<ItemsModel, Config>(
      builder: (BuildContext context, ItemsModel itemsModel, Config config,
          Widget? child) {
        itemsByMonth = itemsModel.itemsByDate.flatten().groupedByMonth();
        String currencyString = config.currencyToString(config.currency);
        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: itemsByMonth.length + topWidget.length,
          itemBuilder: (context, index) {
            if (index < topWidget.length) {
              return topWidget[index];
            }
            final date = itemsByMonth.keys.elementAt(index - topWidget.length);
            final localItems = itemsByMonth[date]!;
            final itemsByCategory = localItems.groupedByCategoryAndSorted();
            final allDates = localItems
                .map((item) =>
                    DateTime.fromMillisecondsSinceEpoch(item.timestamp))
                .map((date) => date.day);
            final fromDate = allDates.fold(31, (a, b) => a < b ? a : b);
            final endDate = allDates.fold(0, (a, b) => a < b ? b : a);
            final currentYear =
                DateTime.fromMillisecondsSinceEpoch(localItems.first.timestamp)
                    .year;
            final thisYear = DateTime.now().year;
            final year = currentYear == thisYear ? '' : currentYear;
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: 16.0, left: 4.0, right: 4.0),
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      "${fromDate.toString().padLeft(2, "0")} - ${endDate.toString().padLeft(2, "0")} ${getMonth(date.$2)} $year",
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            "${localItems.totalCredit().format()} $currencyString",
                            style: const TextStyle(
                                color: Color.fromARGB(255, 219, 68, 55),
                                fontSize: 16),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "${localItems.totalDebit().format()} $currencyString",
                            style: const TextStyle(
                                color: Color.fromARGB(255, 15, 157, 88),
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 4,
                    indent: 15,
                    endIndent: 15,
                  ),
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemsByCategory.length,
                    itemBuilder: (context, index) {
                      final category = itemsByCategory.elementAt(index).name;
                      final total = itemsByCategory.elementAt(index).total;
                      final count = itemsByCategory.elementAt(index).count;
                      return ListTile(
                        visualDensity: VisualDensity.compact,
                        dense: true,
                        title: Row(
                          children: [
                            Text(
                              "$count×",
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const VerticalDivider(),
                            Flexible(
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          "${total.format()} ${currencyString}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
