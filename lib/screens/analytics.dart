import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:walletapp/models/item.dart';
import 'package:walletapp/widgets/chart.dart';
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
                  final itemsByCategory =
                      localItems.groupedByCategoryAndSorted();
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
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "${fromDate} - ${endDate} ${getMonth(date.$2)}",
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Container(
                                  //   // backgroundColor: Colors.red[100],
                                  //   // maxRadius: 16,
                                  //   decoration: BoxDecoration(
                                  //       color: Colors.red[100],
                                  //       borderRadius: new BorderRadius.all(
                                  //           Radius.elliptical(20, 20))),
                                  //   // backgroundColor: Colors.red[100],
                                  //   // maxRadius: 16,
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.only(
                                  //         left: 8.0, right: 8.0),
                                  //     child: Text(
                                  //       "${localItems.totalCredit().format()} DNT",
                                  //       style: TextStyle(
                                  //           color: const Color.fromARGB(
                                  //               255, 219, 68, 55),
                                  //           fontSize: 16),
                                  //     ),
                                  //   ),
                                  // ),
                                  Text(
                                    "${localItems.totalCredit().format()} DNT",
                                    style: const TextStyle(
                                        color: const Color.fromARGB(
                                            255, 219, 68, 55),
                                        fontSize: 16),
                                  ),
                                  Text(
                                    "${localItems.totalDebit().format()} DNT",
                                    style: const TextStyle(
                                        color: const Color.fromARGB(
                                            255, 15, 157, 88),
                                        fontSize: 16),
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
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: itemsByCategory.length,
                          itemBuilder: (context, index) {
                            final category =
                                itemsByCategory.elementAt(index).name;
                            final total =
                                itemsByCategory.elementAt(index).total;
                            final count =
                                itemsByCategory.elementAt(index).count;
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0,
                                  right: 16.0,
                                  bottom: 8.0,
                                  left: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
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
                                                fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text("${total.format()} DNT",
                                      style: TextStyle(fontSize: 15))
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
