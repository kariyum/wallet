import 'dart:async';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:walletapp/app_state/appbar_progress_indicator.dart';
import 'package:walletapp/app_state/items_model.dart';
import 'package:walletapp/app_state/theme_provider.dart';
import 'package:walletapp/models/datetime.dart';
import 'package:walletapp/models/item.dart';
import 'package:walletapp/screens/analytics.dart';
import 'package:walletapp/screens/settings.dart';
import 'package:walletapp/services/database.dart';
import 'package:walletapp/services/firebase.dart';
import 'package:walletapp/widgets/item_input_dialog.dart';
import 'package:walletapp/widgets/reactive_floating_action_buttion.dart';

import '../widgets/animated_count.dart';
import 'main.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController titleController = TextEditingController();
  late TextEditingController priceController;
  late TextEditingController notesController;
  late TextEditingController dateController = TextEditingController();
  late bool futurePaymentCheckbox;

  bool isDialogOpen = false;
  final Firebase firebase = Firebase();

  @override
  void initState() {
    initDb();
    super.initState();
    // skipLockScreen();
    // updateItems();
    titleController = TextEditingController();
    titleController.text = '';

    priceController = TextEditingController();
    priceController.text = '';

    notesController = TextEditingController();
    notesController.text = '';
  }

  void skipLockScreen() async {
    final lpin = await DatabaseRepository.instance.readPin();
    _islocked = lpin.isEmpty ? true : lpin[0] != "-1";
  }

  Future<void> saveAllItems(List<Item> items) {
    return DatabaseRepository.instance.saveAllItems(items);
  }

  void initDb() async {
    // await deleteDatabase();
    await DatabaseRepository.instance.database;
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    notesController.dispose();

    super.dispose();
  }

  Future<List<Item>> getAllItems() async {
    return await DatabaseRepository.instance.getAllItems();
  }

  List<Item> items = [];
  Map<DateTime, List<Item>> itemsByDate = {};

  void updateItems() async {
    await DatabaseRepository.instance.getAllItems().then((value) {
      setState(() {
        items = value;
        itemsByDate = value.groupedByDay();
      });
    }).catchError((e) => debugPrint(e.toString()));
  }

  double totalExpenses() {
    debugPrint("TOTAL EXPENSES");
    final res = items.isEmpty
        ? 0.0
        : items
        .where((e) => e.paid == 1)
        .map((e) => e.price)
        .reduce((priceA, priceB) => priceA + priceB);
    return double.parse((res).toStringAsFixed(3));
  }

  double forecastedExpenses() {
    final res = items.isEmpty
        ? 0.0
        : items.map((e) => e.price).reduce((priceA, priceB) => priceA + priceB);
    return double.parse(
        ((res * 1000).roundToDouble() / 1000).toStringAsFixed(3));
  }

  int isSelected = -1;

  final ScrollController _scrollController = ScrollController();

  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final ThemeProvider themeProvider = context.read<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.transparent,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: themeProvider.isDarkMode() ? Brightness.light : Brightness.dark,
            // systemNavigationBarDividerColor: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 3.0)
          ),
          // backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: Theme
              .of(context)
              .appBarTheme
              .elevation,
          primary: true,
          // toolbarHeight: 0,
          // scrolledUnderElevation: 0.0,
          backgroundColor: AppBarTheme
              .of(context)
              .backgroundColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                [
                  Icons.account_balance_rounded,
                  Icons.query_stats,
                  Icons.settings
                ].elementAt(_currentPageIndex),
                size: 40,
                color: () {
                  if (themeProvider.isDarkMode()) {
                    return Colors.amber[800];
                  }
                  return Colors.amber[400];
                }(),
              ),
              // TextButton(
              //   onPressed: () async {
              //     // inserts 13 months of data
              //     // 5 items per day
              //     int numberOfMonths = 13;
              //     int numberOfItemsPerMonth = 5;
              //     int numberOfItemsPerDay = 3;
              //
              //     Random r = Random();
              //     DateTime currentDate = DateTime.now();
              //     List<String> titles = [
              //       "Milk",
              //       "Chocolate",
              //       "Water",
              //       "Coffee",
              //       "Electricity",
              //       "Mouse",
              //       "Needs",
              //       "Burger"
              //     ];
              //     List<Future<void>> futures = [];
              //     for (int month = 0; month < numberOfMonths; month++) {
              //       currentDate = currentDate.subtract(Duration(days: 31));
              //       for (int itemNumber = 0;
              //           itemNumber < numberOfItemsPerMonth;
              //           itemNumber++) {
              //         Duration randomDays = Duration(days: 1 + r.nextInt(10));
              //         for (int dayNumber = 0; dayNumber < numberOfItemsPerDay; dayNumber++) {
              //           String randomTitle =
              //           titles.elementAt(r.nextInt(titles.length - 1));
              //           int sign = r.nextBool() ? 1 : -1;
              //           double price = sign * r.nextDouble() * 100;
              //           Item item = Item(
              //             title: randomTitle,
              //             price: price,
              //             timestamp: currentDate.add(randomDays).millisecondsSinceEpoch,
              //           );
              //           futures.add(item.persist());
              //         }
              //       }
              //     }
              //     Future.wait(futures);
              //     setState(() {
              //       updateItems();
              //     });
              //   },
              //   child: Text("Generate data"),
              // ),
              const VerticalDivider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome!",
                    style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 117, 117, 117)),
                  ),
                  Text(
                    ["Overview", "Statistics", "Settings"]
                        .elementAt(_currentPageIndex),
                  )
                ],
              ),
            ],
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(6.0),
              child: Consumer<AppbarProgressIndicator>(
                builder: (context, indicator, child) {
                  if (indicator.isLoading) {
                    return const LinearProgressIndicator();
                  }
                  return const SizedBox();
                },
              ))),
      body: [
        Main(scrollController: _scrollController),
        const AnalyticsPage(),
        Settings(),
      ][_currentPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.query_stats),
            icon: Icon(Icons.query_stats_outlined),
            //Badge( label: Text('2'), child: Icon(Icons.query_stats), ),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: ReactiveFloatingActionButton(
        controller: _scrollController,
        onPressed: () async {
          final x = await openFullScreenDialog();

          if (x == null) {
            debugPrint(x.toString());
          } else {
            // await x.persist();
            if (context.mounted) {
              debugPrint("ADDING ITEM");
              Provider.of<ItemsModel>(context, listen: false).add(x);
            }
            // updateItems();
          }
        },
        currentPageIndex: _currentPageIndex,
        visibleOnPageIndex: 0,
        child: const Icon(Icons.add),
      ),
    );
  }

  bool showCurrentBalance = true;
  bool showCardInfo = false;

  Widget homePageWidget(BuildContext context) {
    debugPrint("Building homePageWidget");
    return SingleChildScrollView(
      controller: _scrollController,
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Stack(
            children: [
              Card(
                margin: const EdgeInsets.all(8),
                child: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
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
                              child: () {
                                if (showCardInfo && showCurrentBalance) {
                                  return AnimatedCount(
                                      count: items.availableBalance());
                                }
                                if (showCardInfo && !showCurrentBalance) {
                                  return AnimatedCount(
                                      count: forecastedExpenses());
                                }
                                return const Text(
                                  "---",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }(),
                              // child: Text(
                              //   () {
                              //     if (showCardInfo && showCurrentBalance) {
                              //       return "${items.availableBalance().format()} DNT";
                              //     }
                              //     if (showCardInfo && !showCurrentBalance) {
                              //       return "${forecastedExpenses().format()} DNT";
                              //     }
                              //     return "---";
                              //   }(),
                              //   style: const TextStyle(
                              //     fontSize: 24,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
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
                                  ? "${items.totalCredit().format()} DNT"
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
                                  ? "${items.totalDebit().format()} DNT"
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
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Transactions",
                          style: TextStyle(fontSize: 21),
                        ),
                        Row(
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Uploading...')),
                                  );
                                }
                                final futureDocumentId =
                                firebase.uploadItems(items);
                                futureDocumentId.then((documentId) {
                                  Clipboard.setData(
                                      ClipboardData(text: documentId))
                                      .then((_) =>
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Document id copied to clipboard!')),
                                      ));
                                });
                              },
                              icon: const Icon(Icons.upload),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () async {
                                final futureValue = await openDialogSync();
                                if (futureValue != null) {
                                  // downloading
                                  final futureData =
                                  firebase.downloadItems(futureValue);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Downloading...'),
                                      ),
                                    );
                                  }
                                  // updateItems();
                                  futureData.then((data) {
                                    setState(() {
                                      items = data;
                                      itemsByDate = data.groupedByDay();
                                    });
                                    saveAllItems(data).then((_) =>
                                    {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                          Text('Items saved locally!'),
                                        ),
                                      )
                                    });
                                  });
                                }
                              },
                              icon: const Icon(Icons.download),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                ListView.separated(
                  // controller: _scrollController,
                  separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(
                    height: 20,
                  ),
                  // reverse: true,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itemsByDate.keys.length,
                  itemBuilder: itemBuilderByDate,
                ),
              ],
            ),
          ),

          // Divider(
          //   indent: 40,
          //   endIndent: 40,
          // ),
          // ListView.separated(
          //   // controller: _scrollController,
          //   separatorBuilder: (BuildContext context, int index) =>
          //       const Divider(),
          //   // reverse: true,
          //   scrollDirection: Axis.vertical,
          //   shrinkWrap: true,
          //   physics: NeverScrollableScrollPhysics(),
          //   itemCount: items.length,
          //   itemBuilder: itemBuilderSimple,
          // ),
          // ListView.builder(itemBuilder: itemBuilderDate, itemCount: itemsByDate.length,)
        ],
      ),
    );
  }

  Widget? itemBuilderByDateSub(BuildContext context, int idx,
      List<Item> items) {
    final currentItem = items.elementAt(idx);
    return ListTile(
      visualDensity:
      const VisualDensity(vertical: VisualDensity.minimumDensity),
      onLongPress: () async {
        isSelected = idx;
        await openDialogItem(items[idx]);
        isSelected = -1;
      },
      leading: Icon(
        Icons.wallet,
        color: () {
          if (currentItem.isCredit() && currentItem.paid == 1) {
            return Colors.black54;
          }
          return const Color.fromARGB(255, 66, 133, 244);
        }(), //Theme.of(context).colorScheme.onSurfaceVariant
        size: 26,
      ),
      subtitle: Text(
          "${currentItem.hour!.toString().padLeft(2, '0')}:${currentItem.minute!
              .toString().padLeft(2, '0')}",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          )),
      trailing: Text(
        '${currentItem.price.format()} DNT',
        style: TextStyle(
          fontSize: 18,
          color: () {
            const red = Color.fromARGB(255, 219, 68, 55);
            const green = Color.fromARGB(255, 15, 157, 88);
            const black = Colors.black54;
            if (currentItem.isCredit() && currentItem.paid == 1) {
              return black;
            }
            return currentItem.isCredit() ? red : green;
          }(),
        ),
      ),
      title: Text(
        currentItem.title,
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
    );
    // Dismissible(
    //   key: Key(currentItem.id.toString()),
    // onDismissed: (direction) {
    //   if (direction == DismissDirection.endToStart) {
    //     // DatabaseRepository.instance.deleteItem()
    //   }
    // },
    // secondaryBackground: Container(
    //   color: Colors.red[400],
    //   child: const Padding(
    //     padding: EdgeInsets.all(16.0),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.end,
    //       children: [
    //         Text(
    //           "Delete",
    //           style: TextStyle(
    //             color: Colors.white,
    //             fontSize: 21,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //         SizedBox(
    //           width: 20,
    //         ),
    //         Icon(
    //           Icons.delete,
    //           color: Colors.white,
    //         ),
    //       ],
    //     ),
    //   ),
    // ),
    // background: Container(
    //   color: Colors.green[400],
    //   child: const Padding(
    //     padding: EdgeInsets.all(16.0),
    //     child: Row(
    //       children: [
    //         Icon(
    //           Icons.edit,
    //           color: Colors.white,
    //         ),
    //         SizedBox(
    //           width: 20,
    //         ),
    //         Text(
    //           "Edit",
    //           style: TextStyle(
    //               color: Colors.white,
    //               fontSize: 21,
    //               fontWeight: FontWeight.bold),
    //         ),
    //       ],
    //     ),
    //   ),
    // ),
    // confirmDismiss: (direction) async {
    //   return false; // direction == DismissDirection.endToStart;
    // },
    //   child: ListTile(
    //     onLongPress: () async {
    //       isSelected = idx;
    //       final x = await openDialogItem(items[idx]);
    //       isSelected = -1;
    //     },
    //     leading: Icon(
    //       Icons.wallet,
    //       color: () {
    //         if (currentItem.isCredit() && currentItem.paid == 1) {
    //           return Colors.black54;
    //         }
    //         return const Color.fromARGB(255, 66, 133, 244);
    //       }(), //Theme.of(context).colorScheme.onSurfaceVariant
    //       size: 26,
    //     ),
    //     subtitle: Text(
    //         "${currentItem.hour!.toString().padLeft(2, '0')}:${currentItem.minute!.toString().padLeft(2, '0')}",
    //         style: TextStyle(
    //           fontSize: 14,
    //           color: Colors.grey[600],
    //         )),
    //     trailing: Text(
    //       '${currentItem.price.format()} DNT',
    //       style: TextStyle(
    //         fontSize: 18,
    //         color: currentItem.paid == 1
    //             ? currentItem.isCredit()
    //                 ? const Color.fromARGB(255, 219, 68, 55)
    //                 : const Color.fromARGB(255, 15, 157, 88)
    //             : Colors.black54,
    //       ),
    //     ),
    //     title: Text(
    //       currentItem.title,
    //       style: TextStyle(
    //         fontSize: 18,
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget? itemBuilderByDate(BuildContext context, int idx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            itemsByDate.keys.elementAt(idx).formatListTile(),
            style: TextStyle(fontSize: 18),
          ),
        ),
        const Divider(
          height: 4,
          indent: 14,
          endIndent: 10,
        ),
        ListView.builder(
          // separatorBuilder: (context, index) => Divider(
          //  indent: 20,
          //  endIndent: 20,
          //  height: 0,
          // ),
          itemCount: itemsByDate.values
              .elementAt(idx)
              .length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, j) {
            return itemBuilderByDateSub(
                context, j, itemsByDate.values.elementAt(idx));
          },
        ),
        // for (var elementIndex = 0;
        //     elementIndex < itemsByDate.values.elementAt(idx).length;
        //     elementIndex += 1)
        //   ListTile(
        //     title: Text(itemsByDate.values
        //         .elementAt(idx)
        //         .elementAt(elementIndex)
        //         .title),
        //   )
      ],
    );
  }

  Widget? itemBuilderSimple(BuildContext context, int idx) {
    // idx = items.length - idx - 1;
    return ListTile(
      onLongPress: () async {
        isSelected = idx;
        final x = await openDialogItem(items[idx]);
        isSelected = -1;
      },
      leading: Icon(
        Icons.paid,
        color: items[idx].paid == 1
            ? const Color.fromARGB(255, 66, 133, 244)
            : Colors.black54, //Theme.of(context).colorScheme.onSurfaceVariant
        size: 26,
      ),
      subtitle: Text(items[idx].note(),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          )),
      trailing: Text(
        '${items[idx].price.format()} DNT',
        style: TextStyle(
          fontSize: 18,
          color: items[idx].paid == 1
              ? items[idx].isCredit()
              ? const Color.fromARGB(255, 219, 68, 55)
              : const Color.fromARGB(255, 15, 157, 88)
              : Colors.black54,
        ),
      ),
      title: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(
            child: Text(
              items[idx].title,
              style: const TextStyle(
                fontSize: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _islocked = true;

  Widget showLockScreen() {
    return PopScope(
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            const Text("Welcome"),
            const Text("Enter your PIN please"),
            Center(
              child: SizedBox(
                width: 300,
                child: TextFormField(
                  onFieldSubmitted: (value) async {
                    // await DatabaseRepository.instance.deletePin();
                    // debugPrint("Deleting pin");
                    final x = await DatabaseRepository.instance.readPin();
                    if (x.isEmpty) {
                      value = value.isEmpty ? "-1" : value;
                      await DatabaseRepository.instance.insertPin(pin: value);
                      // final xx = await DatabaseRepository.instance.readPin();
                      // debugPrint(xx.toString());
                      setState(() {
                        _islocked = false;
                      });
                    } else {
                      if (x[0].toString() == value) {
                        setState(() {
                          _islocked = false;
                        });
                      }
                    }
                  },
                  textAlign: TextAlign.center,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'PIN',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool isChecked = false;

  final _formKey = GlobalKey<FormState>();

  Future<Item?> openFullScreenDialog({Item? defaultItem}) {
    titleController.text = '';
    priceController.text = '';
    notesController.text = '';
    dateController.text = '';
    isChecked = false;
    return showGeneralDialog(
      context: context,
      pageBuilder: (ctx, a, b) =>
          Dialog.fullscreen(
            child: ItemInputDialog(
              formkey: _formKey,
              notesController: notesController,
              titleController: titleController,
              priceController: priceController,
              dateController: dateController,
              items: context
                  .read<ItemsModel>()
                  .items,
              defaultItem: defaultItem,
            ),
          ),
    );
  }

  Future<Item?> openDialogItem(Item a) {
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      // barrierColor: Colors.black38,
      transitionDuration: Durations.short4,
      context: context,
      // barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.1),
      transitionBuilder: (ctx, anim1, anim2, child) =>
          BackdropFilter(
            filter:
            ImageFilter.blur(sigmaX: 2 * anim1.value, sigmaY: 2 * anim1.value),
            child: FadeTransition(
              opacity: anim1,
              child: child,
            ),
          ),
      pageBuilder: (context, anim1, anim2) =>
          AlertDialog(
            // actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsPadding:
            const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 8.0),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(null);
                  if (a.isCredit()) {
                    await a.itemSwitchPaid().then((value) {
                      updateItems();
                    });
                  }
                  return;
                },
                child: const Text(
                  "Paid",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await DatabaseRepository.instance
                      .deleteItem(a.id!)
                      .then((value) =>
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction deleted !')),
                      ));
                  setState(() {
                    items = items.where((item) => item.id != a.id).toList();
                    itemsByDate = items.groupedByDay();
                    isSelected = -1;
                    Navigator.of(context).pop(null);
                  });
                },
                child: const Text("Delete",
                    style: TextStyle(
                      fontSize: 18.0,
                    )),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(null);
                  final itemToInsert = await openFullScreenDialog(
                      defaultItem: a);
                  if (itemToInsert != null) {
                    await itemToInsert.persist();
                    setState(() {
                      updateItems();
                    });
                  }
                  return;
                },
                child: const Text(
                  "Edit",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
            elevation: 10.0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black,
            // backgroundColor: Colors.amber,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(a.title),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                ),
                Column(
                  children: [
                    Text(
                      a.price.format(),
                      style: TextStyle(
                        fontSize: 21,
                        color: a.isCredit()
                            ? const Color.fromARGB(255, 219, 68, 55)
                            : const Color.fromARGB(255, 15, 157, 88),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            content: SizedBox(
              width: 400,
              // height: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    a.formatDate(),
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (a.notes != null && a.notes! != "")
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        (a.notes != null) ? a.notes! : "",
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    )
                  else
                    const Text(
                      "No description is available.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  // Align(
                  //   alignment: Alignment.bottomLeft,
                  //   child: Text(
                  //     a.note(),
                  //     style: TextStyle(
                  //       fontSize: 18.0,
                  //       color: Colors.grey[600],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
    );
  }

  Future<String?> openDialogSync() {
    TextEditingController idController = TextEditingController();
    return showGeneralDialog<String?>(
      barrierDismissible: true,
      barrierLabel: '',
      // barrierColor: Colors.black38,
      transitionDuration: Durations.short4,
      context: context,
      // barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.1),
      transitionBuilder: (ctx, anim1, anim2, child) =>
          BackdropFilter(
            filter:
            ImageFilter.blur(sigmaX: 2 * anim1.value, sigmaY: 2 * anim1.value),
            child: FadeTransition(
              opacity: anim1,
              child: child,
            ),
          ),
      pageBuilder: (context, anim1, anim2) =>
          AlertDialog(
            // actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsPadding:
            const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 8.0),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(idController.text);
                },
                child: const Text(
                  "Download",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
            elevation: 10.0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black,
            // backgroundColor: Colors.amber,
            title: const Text("Sync"),
            content: SizedBox(
              width: 400,
              // height: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextField(
                    controller: idController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      labelText: 'Document id',
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    textInputAction: TextInputAction.newline,
                  )
                ],
              ),
            ),
          ),
    );
  }
}
