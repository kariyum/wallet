import 'package:flutter/material.dart';
import 'package:walletapp/models/item.dart';
import 'package:walletapp/widgets/stats.dart';
import 'package:walletapp/services/utils.dart';

class AnalyticsPage extends StatefulWidget {
  AnalyticsPage({
    super.key,
    required this.itemsByDate,
  });

  final Map<DateTime, List<Item>> itemsByDate;
  Map<(int, int), List<Item>> itemsByMonth = {};
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    widget.itemsByMonth = widget.itemsByDate.flatten().groupedByMonth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.itemsByMonth = widget.itemsByDate.flatten().groupedByMonth();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 16.0),
                child: Text(
                  "Overall expenses",
                  style: TextStyle(fontSize: 21),
                ),
              ),
              SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SimpleTimeSeriesChart.fromItemsGrouped(
                      widget.itemsByDate),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 16.0),
                child: Text(
                  "Monthly expenses",
                  style: TextStyle(fontSize: 21),
                ),
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.itemsByMonth.length,
                itemBuilder: (context, index) {
                  final date = widget.itemsByMonth.keys.elementAt(index);
                  final localItems = widget.itemsByMonth[date]!;
                  final itemsByCategory = localItems.groupedByCategoryAndSorted();
                  final allDates = localItems
                      .map((item) =>
                          DateTime.fromMillisecondsSinceEpoch(item.timestamp))
                      .map((date) => date.day);
                  final fromDate = allDates.fold(31, (a, b) => a < b ? a : b);
                  final endDate = allDates.fold(0, (a, b) => a < b ? b : a);
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "${fromDate} - ${endDate} ${getMonth(date.$2)}",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${localItems.totalCredit().format()} TND",
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 219, 68, 55),
                                        fontSize: 18),
                                  ),
                                  Text(
                                    "${localItems.totalDebit().format()} TND",
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 15, 157, 88),
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const Divider(
                          height: 0,
                          indent: 15,
                          endIndent: 15,
                        ),
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: itemsByCategory.length,
                          itemBuilder: (context, index) {
                            final category = itemsByCategory.elementAt(index).key;
                            final total = itemsByCategory.elementAt(index).value;
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${category}",
                                    style: TextStyle(
                                      fontSize: 18
                                    ),
                                  ),
                                  Text("${total.format()} DNT")
                                ],
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  );
                },
              )
              // ListView.builder(
              //   scrollDirection: Axis.vertical,
              //   shrinkWrap: true,
              //   physics: NeverScrollableScrollPhysics(),
              //   itemCount: widget.itemsByMonth.length,
              //   itemBuilder: (context, index) {
              //     final date = widget.itemsByMonth.keys.elementAt(index);
              //     final localItems = widget.itemsByMonth[date]!;
              //     final itemsByCategory = localItems.groupedByCategory();
              //     return Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Padding(
              //             padding: const EdgeInsets.all(8.0),
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 Text(
              //                   getMonth(date.$2),
              //                   style: TextStyle(fontSize: 21),
              //                 ),
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.end,
              //                   children: [
              //                     Text(
              //                         "${localItems.totalCredit().format()} DNT"),
              //                     Text(
              //                         "${localItems.totalDebit().format()} DNT"),
              //                   ],
              //                 )
              //               ],
              //             ),
              //           ),
              //         ),
              //         Divider(
              //           indent: 10,
              //           endIndent: 10,
              //         ),
              //         ListView.builder(
              //           scrollDirection: Axis.vertical,
              //           shrinkWrap: true,
              //           physics: NeverScrollableScrollPhysics(),
              //           itemCount: itemsByCategory.length,
              //           itemBuilder: (context, index) {
              //             final category =
              //                 itemsByCategory.keys.elementAt(index);
              //             final items = itemsByCategory[category]!;
              //             final total = items.availableBalance();
              //             return Padding(
              //               padding: const EdgeInsets.all(16.0),
              //               child: Row(
              //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                 children: [
              //                   Text("${category}"),
              //                   Text("${total.format()} DNT")
              //                 ],
              //               ),
              //             );
              //           },
              //         )
              //       ],
              //     );
              //   },
              // )
            ],
          )
        ],
      ),
    );
  }
}
