import 'package:flutter/material.dart';
import 'package:walletapp/services/database.dart';
import 'package:walletapp/models/item.dart';
import 'package:flutter/scheduler.dart';
import 'package:walletapp/widgets/homepage_upper.dart';
import 'package:walletapp/widgets/item_input_dialog.dart';
import 'dart:ui';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController titleController = TextEditingController();
  late TextEditingController priceController;
  late TextEditingController notesController;
  late bool futurePaymentCheckbox;

  bool isDialogOpen = false;

  @override
  void initState() {
    initDb();
    super.initState();
    skipLockScreen();
    updateItems();
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
    // setState(() {
    //   debugPrint("IS LOCKED $_islocked");
    //   debugPrint("LPIN[0] ${lpin[0]}");
    // });
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

  Future<List<Item>> getAllItmes() async {
    return await DatabaseRepository.instance.getAllItems();
  }

  List<Item> items = [];
  void updateItems() async {
    await DatabaseRepository.instance.getAllItems().then((value) {
      setState(() {
        items = value;
        // groupItemsByDate();
      });
    }).catchError((e) => debugPrint(e.toString()));
  }

  double totalExpenses() {
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
        : items
            // .where((e) => e.paid == 1)
            .map((e) => e.price)
            .reduce((priceA, priceB) => priceA + priceB);
    return double.parse(
        ((res * 1000).roundToDouble() / 1000).toStringAsFixed(3));
  }

  Map<String, List<Item>> itemsByDate = {};
  List<Widget> flattened = [];
  void groupItemsByDate() {
    // updateItems();
    for (int i = 0; i < items.length; i++) {
      Item itm = items[i];
      String mapKey = '${itm.day}/${itm.month}/${itm.year}';

      if (!itemsByDate.containsKey(mapKey)) {
        itemsByDate[mapKey] = <Item>[itm];
      } else {
        itemsByDate[mapKey]!.add(itm);
      }
      // debugPrint(itemsByDate.toString());
    }
    flattenItemsByDate();
  }

  void flattenItemsByDate() {
    List<Widget> res = <Widget>[];
    for (final entry in itemsByDate.entries) {
      res.add(Text('${entry.key} category'));
      res.add(Container(
        padding: EdgeInsets.zero,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          color: Theme.of(context).colorScheme.background,
        ),
        child: Column(
          children: [
            for (final value in entry.value)
              ListTile(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value.title,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${value.price.toString()} DT',
                      style: TextStyle(
                        fontSize: 18,
                        color: value.isCredit()
                            ? const Color.fromARGB(255, 219, 68, 55)
                            : const Color.fromARGB(255, 15, 157, 88),
                      ),
                    )
                  ],
                ),
              )
          ],
        ),
      ));
    }
    flattened = res;
  }

  int isSelected = -1;

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    debugPrint("rebuilding");
    // if (_islocked == false) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) =>
    //       _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
    // }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context)
            .colorScheme
            .surface, //Theme.of(context).colorScheme.primaryContainer,
        primary: true,
        toolbarHeight: 10,
        scrolledUnderElevation: 0.0,
        // title: const Center(
        //   child: Text("Wallet"),
        // ),
      ),
      body: _islocked ? showLockScreen() : homePageWidget(context),
    );
  }

  bool currentBalance = true;

  Widget homePageWidget(BuildContext context) {
    return Column(
      children: [
        HomePageFirstHalf(items: items),
        SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(8.0),
                child: Text(
                  "Transactions",
                  style: Theme.of(context).textTheme.titleLarge,
                  // style: TextStyle(
                  //   fontSize: 18,
                  //   fontWeight: FontWeight.bold,
                  // ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: () async {
                    // Navigator.of(context)
                    //     .push(MaterialPageRoute<void>(
                    //   builder: (context) => openDialog(),
                    // ));
                    // openDialog();
                    // final x = await openDialog2();
                    final x = await openFullScreenDialog();
                    if (x == null) {
                      debugPrint(x.toString());
                    } else {
                      setState(() {
                        x.persist();
                        updateItems();
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              )
            ],
          ),
        ),
        Flexible(
          child: ListView.separated(
            controller: _scrollController,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            // reverse: true,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            // padding: EdgeInsets.all(16.0),
            // itemCount: flattened.length,
            // itemBuilder: (context, i) {
            //   return flattened[i];
            // },
            itemCount: items.length,
            itemBuilder: itemBuilderSimple,
          ),
        ),
      ],
    );
  }

  Widget? itemBuilderDate(BuildContext context, int idx) {
    return ListView.separated(
      controller: _scrollController,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      padding: const EdgeInsets.all(8.0),
      reverse: true,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: itemsByDate.keys.toList()[idx].length,
      itemBuilder: (_, i) {
        return ListTile(
          leading: Icon(
            itemsByDate[itemsByDate.keys.toList()[idx]]![i].isCredit()
                ? Icons.shopping_bag
                : Icons.paid,
            color: Colors.blue[300],
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                itemsByDate[itemsByDate.keys.toList()[idx]]![i].title,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                '${itemsByDate[itemsByDate.keys.toList()[idx]]![i].price.toString()} DT',
                style: TextStyle(
                  fontSize: 18,
                  color:
                      itemsByDate[itemsByDate.keys.toList()[idx]]![i].isCredit()
                          ? const Color.fromARGB(255, 219, 68, 55)
                          : const Color.fromARGB(255, 15, 157, 88),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget? itemBuilderSimple(BuildContext context, int idx) {
    idx = items.length - idx - 1;
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
        '${items[idx].price.toString()} DT',
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
    return WillPopScope(
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
        onWillPop: () => Future.value(true));
  }

  bool isChecked = false;

  final _formKey = GlobalKey<FormState>();

  Future<Item?> openFullScreenDialog() {
    titleController.text = '';
    priceController.text = '';
    notesController.text = '';
    isChecked = false;

    return showGeneralDialog(
      context: context,
      pageBuilder: (context, a, b) => Dialog.fullscreen(
        child: ItemInputDialog(
          formkey: _formKey,
          notesController: notesController,
          titleController: titleController,
          priceController: priceController,
          items: items,
        ),
      ),
    );
  }

  Future<Item?> openDialogItem(Item a) {
    // titleController.text = a.note();
    debugPrint(a.toString());
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38,
      // transitionDuration: Duration(milliseconds: 200),
      context: context,
      // barrierDismissible: false,
      // barrierColor: Colors.black.withOpacity(0.1),
      // transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
      //   filter:
      //       ImageFilter.blur(sigmaX: 2 * anim1.value, sigmaY: 2 * anim1.value),
      //   child: FadeTransition(
      //     opacity: anim1,
      //     child: child,
      //   ),
      // ),
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        // actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding:
            const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 8.0),
        actions: [
          // if (a.isCredit())
          //   TextButton(
          //     onPressed: () async {
          //       a
          //           .itemSwitchPaid(a.paid == 1 ? 0 : 1)
          //           .then((value) => ScaffoldMessenger.of(context).showSnackBar(
          //                 const SnackBar(
          //                     content: Text('Transaction updated !')),
          //               ));
          //       setState(() {
          //         updateItems();
          //         Navigator.of(context).pop(null);
          //       });
          //     },
          //     child: const Text("Paid",
          //         style: TextStyle(
          //           fontSize: 18,
          //         )),
          //   ),
          TextButton(
            onPressed: () async {
              await DatabaseRepository.instance
                  .deleteItem(items[isSelected].id!)
                  .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction deleted !')),
                      ));
              setState(() {
                items = items
                    .where((item) => item.id != items[isSelected].id)
                    .toList();
                isSelected = -1;
                Navigator.of(context).pop(null);
              });
            },
            child: const Text("Delete",
                style: TextStyle(
                  fontSize: 18.0,
                )),
          ),
          // TextButton(
          //   onPressed: () {},
          //   child: Text(
          //     "Modify",
          //     style: TextStyle(
          //       fontSize: 18.0,
          //     ),
          //   ),
          // )
        ],
        elevation: 10.0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
        // backgroundColor: Colors.amber,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  a.price.toString(),
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
              if (a.notes != null && a.notes! != "")
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    (a.notes != null) ? a.notes! : "",
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
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
}
