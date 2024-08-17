import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:walletapp/models/datetime.dart';

import '../AppState/items_model.dart';
import '../models/item.dart';
import '../services/database.dart';
import '../services/firebase.dart';
import '../widgets/animated_count.dart';
import '../widgets/card_info.dart';
import '../widgets/item_input_dialog.dart';

class Main extends StatefulWidget {
  final ScrollController scrollController;

  const Main({
    super.key,
    required this.scrollController,
  });

  @override
  State<Main> createState() => MainState();
}

class MainState extends State<Main> {
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
    super.initState();
  }

  final firestore = Firebase();
  bool isChecked = false;
  final _formKey = GlobalKey<FormState>();
  int isSelected = -1;
  bool showCurrentBalance = true;
  bool showCardInfo = false;
  Map<DateTime, List<Item>> itemsByDate = {};
  List<Item> items = [];
  late TextEditingController titleController = TextEditingController();
  late TextEditingController priceController;
  late TextEditingController notesController;
  late TextEditingController dateController = TextEditingController();
  late bool futurePaymentCheckbox;

  bool isDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    print("REBUILDING MAIN");
    return ListView(
      shrinkWrap: true,
      controller: widget.scrollController,
      children: [
        const CardInfo(),
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
                              final futureDocumentId = firestore.uploadItems(
                                  Provider.of<ItemsModel>(context,
                                          listen: false)
                                      .items);
                              futureDocumentId.then((documentId) {
                                Clipboard.setData(
                                        ClipboardData(text: documentId))
                                    .then((_) => ScaffoldMessenger.of(context)
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
                                    firestore.downloadItems(futureValue);
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
                                    Provider.of<ItemsModel>(context,
                                            listen: false)
                                        .set(data);
                                    //items = data;

                                    //itemsByDate = data.groupedByDay();
                                  });
                                  saveAllItems(data).then((_) => {
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
              Consumer<ItemsModel>(builder: (context, itemsModel, child) {
                return ListView.separated(
                  // controller: _scrollController,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(
                    height: 20,
                  ),
                  // reverse: true,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itemsModel.itemsByDate.keys.length,
                  itemBuilder: (BuildContext context, int idx) => itemBuilderByDate(context, idx, itemsModel.itemsByDate),
                );
              }),
            ],
          ),
        ),
      ],
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
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: 2 * anim1.value, sigmaY: 2 * anim1.value),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      ),
      pageBuilder: (context, anim1, anim2) => AlertDialog(
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

  Widget? itemBuilderByDate(BuildContext context, int idx, Map<DateTime, List<Item>> itemsByDate) {
    debugPrint("ItemBuilderBydate");
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
          itemCount: itemsByDate.values.elementAt(idx).length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, j) {
            return itemBuilderByDateSub(
                context, j, itemsByDate.values.elementAt(idx));
          },
        ),
      ],
    );
  }

  Future<void> saveAllItems(List<Item> items) {
    return DatabaseRepository.instance.saveAllItems(items);
  }

  Widget? itemBuilderByDateSub(
      BuildContext context, int idx, List<Item> items) {
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
          "${currentItem.hour!.toString().padLeft(2, '0')}:${currentItem.minute!.toString().padLeft(2, '0')}",
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
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: 2 * anim1.value, sigmaY: 2 * anim1.value),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      ),
      pageBuilder: (context, anim1, anim2) => AlertDialog(
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
                  .then((value) => ScaffoldMessenger.of(context).showSnackBar(
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
              final itemToInsert = await openFullScreenDialog(defaultItem: a);
              if (itemToInsert != null) {
                await itemToInsert.persist();
                setState(() {
                  updateItems();
                });
              }
              return;
            },
            child: Text(
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

  void updateItems() async {
    await DatabaseRepository.instance.getAllItems().then((value) {
      setState(() {
        items = value;
        itemsByDate = value.groupedByDay();
      });
    }).catchError((e) => debugPrint(e.toString()));
  }

  Future<Item?> openFullScreenDialog({Item? defaultItem}) {
    titleController.text = '';
    priceController.text = '';
    notesController.text = '';
    dateController.text = '';
    isChecked = false;
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, a, b) => Dialog.fullscreen(
        child: ItemInputDialog(
          formkey: _formKey,
          notesController: notesController,
          titleController: titleController,
          priceController: priceController,
          dateController: dateController,
          items: items,
          defaultItem: defaultItem,
        ),
      ),
    );
  }

  void initDb() async {
    // await deleteDatabase();
    await DatabaseRepository.instance.database;
  }
}
