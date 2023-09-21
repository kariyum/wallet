import 'package:flutter/material.dart';
import 'package:walletapp/services/database.dart';
import 'package:walletapp/models/item.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController titleController;
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
    return double.parse(
        ((res * 1000).roundToDouble() / 1000).toStringAsFixed(3));
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
  // final ScrollController _controller = ScrollController();
  void _animateToIndex(int index) {
    _scrollController.animateTo(
      index * -200,
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

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
        Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.all(8.0),
              child: Text(
                currentBalance ? "Current Balance" : "Future Balance",
                // style: TextStyle(
                //   fontSize: 24,
                //   fontWeight: FontWeight.bold,
                // ),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Center(
              child: SizedBox(
                height: 130,
                child: Center(
                  child: Text(
                    // '${totalExpenses().toString()} DT',
                    currentBalance
                        ? totalExpenses().toString()
                        : forecastedExpenses().toString(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
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
        Flexible(
          child: Stack(
            children: [
              Container(
                color: Theme.of(context).colorScheme.background,
                child: ListView.separated(
                  controller: _scrollController,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  // reverse: true,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  // padding: EdgeInsets.all(16.0),
                  // itemCount: flattened.length,
                  // itemBuilder: (context, i) {
                  //   return flattened[i];
                  // },
                  itemCount: items.length,
                  itemBuilder: itemBuilderSimple,
                ),
              ),
              // if (isSelected != -1)
              //   Container(
              //     padding: const EdgeInsets.only(bottom: 10.0),
              //     alignment: Alignment.bottomCenter,
              //     child: TapRegion(
              //       onTapOutside: (event) {
              //         setState(() {
              //           isSelected = -1;
              //         });
              //       },
              //       child: Container(
              //         height: 70,
              //         child: Flex(
              //           direction: Axis.horizontal,
              //           mainAxisAlignment: MainAxisAlignment.spaceAround,
              //           crossAxisAlignment: CrossAxisAlignment.stretch,
              //           children: [
              //             Flexible(
              //               fit: FlexFit.tight,
              //               child: Container(
              //                 child: ElevatedButton(
              //                   style: OutlinedButton.styleFrom(
              //                     shape: CircleBorder(),
              //                   ),
              //                   child: const Padding(
              //                     padding: EdgeInsets.all(12.0),
              //                     child: Column(
              //                       children: [
              //                         Icon(Icons.delete),
              //                         Text('Delete')
              //                       ],
              //                     ),
              //                   ),
              //                   onPressed: () async {
              //                     // debugPrint("DELTED ????");
              //                     await DatabaseRepository.instance
              //                         .deleteItem(items[isSelected].id!)
              //                         .then((value) =>
              //                             ScaffoldMessenger.of(context)
              //                                 .showSnackBar(
              //                               const SnackBar(
              //                                   content: Text(
              //                                       'Transaction deleted !')),
              //                             ));
              //                     setState(() {
              //                       items = items
              //                           .where((item) =>
              //                               item.id != items[isSelected].id)
              //                           .toList();
              //                       isSelected = -1;
              //                     });
              //                   },
              //                 ),
              //               ),
              //             ),
              //             // This is for the EDIT button
              //             // Flexible(
              //             //   fit: FlexFit.tight,
              //             //   child: Container(
              //             //     child: IconButton(
              //             //       style: ButtonStyle(
              //             //         shape: MaterialStateProperty.all<
              //             //             RoundedRectangleBorder>(
              //             //           const RoundedRectangleBorder(
              //             //             borderRadius: BorderRadius.zero,
              //             //           ),
              //             //         ),
              //             //       ),
              //             //       icon: const Column(
              //             //         children: [Icon(Icons.edit), Text('Edit')],
              //             //       ),
              //             //       onPressed: () {

              //             //       },
              //             //     ),
              //             //   ),
              //             // ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   )
            ],
          ),
        ),
      ],
    );
  }

  Widget? itemBuilderDate(BuildContext context, int idx) {
    debugPrint((itemsByDate).length.toString());
    for (int i = 0; i < itemsByDate.length; i++) {
      final x = itemsByDate[itemsByDate.keys.toList()[i]]![0];
      debugPrint(itemsByDate[itemsByDate.keys.toList()[i]].toString());
    }
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
      // shape: Border(),

      // children: [
      //   TextButton(
      //     onPressed: (){},
      //     child: Text("delete"),
      //   )
      // ],
      // selected: isSelected == idx,
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

  void _credit() {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction saved !')),
      );
      final thisItem = Item(
        price: 0 - double.parse(priceController.text),
        title: titleController.text,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        notes: notesController.text,
        paid: isChecked ? 0 : 1,
      );
      Navigator.of(context).pop(thisItem);
    }
  }

  Future<Item?> openFullScreenDialog() {
    titleController.text = '';
    priceController.text = '';
    notesController.text = '';
    isChecked = false;

    return showGeneralDialog(
      context: context,
      pageBuilder: (context, a, b) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 70.0,
            title: const Text("New transaction"),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          bottomNavigationBar: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction saved !')),
                      );
                      final thisItem = Item(
                        price: double.parse(priceController.text),
                        title: titleController.text,
                        timestamp: DateTime.now().millisecondsSinceEpoch,
                        notes: notesController.text,
                        paid: 1,
                      );
                      // debugPrint(thisItem.toString());
                      Navigator.of(context).pop(thisItem);
                    }
                  },
                  child: const Text(
                    "Debit",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                  onPressed: () {
                    _credit();
                  },
                  child: const Text(
                    "Credit",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        // child: Autocomplete<String>(
                        //   optionsBuilder:
                        //       (TextEditingValue textEditingValue) {
                        //     if (textEditingValue.text == '') {
                        //       return const Iterable<String>.empty();
                        //     }
                        //     return ["ok", "hello"].where((String option) {
                        //       return option.contains(
                        //           textEditingValue.text.toLowerCase());
                        //     });
                        //   },
                        //   onSelected: (String selection) {
                        //     debugPrint('You just selected $selection');
                        //   },
                        // ),
                        child: Autocomplete(
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 285),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return InkWell(
                                        onTap: () {
                                          onSelected(option);
                                        },
                                        child: Builder(
                                            builder: (BuildContext context) {
                                          final bool highlight =
                                              AutocompleteHighlightedOption.of(
                                                      context) ==
                                                  index;
                                          if (highlight) {
                                            SchedulerBinding.instance
                                                .addPostFrameCallback(
                                                    (Duration timeStamp) {
                                              Scrollable.ensureVisible(context,
                                                  alignment: 0.5);
                                            });
                                          }
                                          return Container(
                                            color: highlight
                                                ? Theme.of(context).focusColor
                                                : null,
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(option),
                                          );
                                        }),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          displayStringForOption: (option) => option,
                          optionsBuilder: (textEditingValue) {
                            final x = items.map((e) => e.title).toList();
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            } else {
                              return x.toSet().where((e) => e
                                  .toLowerCase()
                                  .startsWith(
                                      textEditingValue.text.toLowerCase()));
                            }
                          },
                          fieldViewBuilder: (BuildContext context,
                              TextEditingController fieldTextEditingController,
                              FocusNode fieldFocusNode,
                              VoidCallback onFieldSubmitted) {
                            fieldTextEditingController.addListener(() {
                              titleController.text =
                                  fieldTextEditingController.text;
                            });
                            return TextFormField(
                              focusNode: fieldFocusNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                titleController.text =
                                    titleController.text.trim();
                                return null;
                              },
                              textCapitalization: TextCapitalization.sentences,
                              controller: fieldTextEditingController,
                              autofocus: true,
                              decoration: const InputDecoration(
                                alignLabelWithHint: true,
                                labelText: 'Item',
                                labelStyle: TextStyle(
                                  fontSize: 18,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                            );
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a number';
                            }
                            priceController.text =
                                priceController.text.replaceAll(',', '.');
                            value = priceController.text;
                            RegExp pattern = RegExp(r'^[0-9][0-9]*\.?[0-9]*$');
                            if (!pattern.hasMatch(value)) {
                              return 'Please insert only numbers';
                            }
                            return null;
                          },
                          controller: priceController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                              labelText: 'Price',
                              labelStyle: TextStyle(
                                fontSize: 18,
                              )
                              // border: OutlineInputBorder(),
                              ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (value) {
                            _credit();
                          },
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 16.0)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        child: TextField(
                          controller: notesController,
                          // minLines: 4,
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                            labelText: 'Description',
                            labelStyle: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                      //   child: CustomCheckBox(
                      //     onChanged: (bool value) {
                      //       isChecked = value;
                      //       print("here changing value $isChecked");
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

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

class CustomCheckBox extends StatefulWidget {
  final ValueChanged<bool> onChanged;

  const CustomCheckBox({
    super.key,
    required this.onChanged,
  });

  @override
  State<CustomCheckBox> createState() => CustomCheckBoxState();
}

class CustomCheckBoxState extends State<CustomCheckBox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          SizedBox(
            height: 18,
            width: 18,
            child: Checkbox(
              value: isChecked,
              onChanged: (value) => {
                setState(() {
                  isChecked = value!;
                  widget.onChanged(isChecked);
                })
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: TapRegion(
              onTapInside: (event) => {
                setState(() {
                  isChecked = !isChecked;
                  widget.onChanged(isChecked);
                })
              },
              child: const Text(
                "Future payment",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
