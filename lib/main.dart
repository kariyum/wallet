import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/scheduler.dart';
// import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class Item {
  final int? id;
  final String title;
  final double price;
  final int timestamp;
  final int? day;
  final int? hour;
  final int? minute;
  final int? month;
  final int? year;

  const Item({
    this.id,
    this.day,
    this.hour,
    this.minute,
    this.month,
    this.year,
    required this.title,
    required this.price,
    required this.timestamp,
  });

  factory Item.fromJson(Map<String, dynamic> map) {
    DateTime d =
        DateTime.fromMillisecondsSinceEpoch(map['timestamp']).toLocal();
    debugPrint(Item(
      id: map['id'],
      price: map['price'],
      timestamp: map['timestamp'],
      title: map['title'],
      day: d.day,
      hour: d.hour,
      minute: d.minute,
      month: d.month,
      year: d.year,
    ).toString());
    return Item(
      id: map['id'],
      price: map['price'],
      timestamp: map['timestamp'],
      title: map['title'],
      day: d.day,
      month: d.month,
      hour: d.hour,
      minute: d.minute,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title[0].toUpperCase() + title.substring(1), 'price': price, 'timestamp': timestamp};
  }

  @override
  String toString() {
    return 'Item(id: $id, title: $title, price: $price, day: $day, month: $month, hour: $hour, minute: $minute)';
  }

  Future<void> persist() async {
    await DatabaseRepository.instance.insertItem(item: this);
  }

  bool isCredit() {
    return price < 0;
  }

  String note() {
    List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    String s = '';
    switch (month) {
      case 1:
        s = 'st';
        break;
      case 2:
        s = 'nd';
        break;
      case 3:
        s = 'rd';
        break;
      default:
        s = 'th';
    }

    return '${months[month! - 1]} ${day.toString()}$s';
  }

  Future<void> delete(id) async {
    await DatabaseRepository.instance.deleteItem(id);
  }
}

class DatabaseRepository {
  static final DatabaseRepository instance = DatabaseRepository._init();
  DatabaseRepository._init();

  Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wallet.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // await deleteDatabase("wallet.db");
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT, 
      price REAL, 
      timestamp INTEGER
    ) ''');

    await db.execute('''CREATE TABLE users (
      pin TEXT PRIMARY KEY
    ) ''');
  }

  Future<void> insertItem({required Item item}) async {
    try {
      final db = await instance.database;
      await db.insert('items', item.toMap());
      debugPrint('inserted');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> insertPin({required String pin}) async {
    try {
      final db = await instance.database;
      await db.insert('users', {'pin': pin});
      debugPrint('inserted');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deletePin() async {
    try {
      final db = await instance.database;
      await db.delete('users');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      final db = await instance.database;
      await db.delete(
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<String>> readPin() async {
    final db = await instance.database;

    final result = await db.query('users');

    return result.map((json) => json['pin'].toString()).toList();
  }

  Future<List<Item>> getAllItems() async {
    final db = await instance.database;

    final result = await db.query('items');

    return result.map((json) => Item.fromJson(json)).toList();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet',
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 8, 116, 178)),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController titleController;
  late TextEditingController priceController;

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
  }

  void skipLockScreen() async {
    final lpin = await DatabaseRepository.instance.readPin();
    _islocked = lpin.isEmpty ? true : lpin[0] != "-1";
    // setState(() {
    //   debugPrint("IS LOCKED $_islocked");
    //   debugPrint("LPIN[0] ${lpin[0]}");
    // });
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'wallet.db');
    databaseFactory.deleteDatabase(path);
  }

  void initDb() async {
    // await deleteDatabase();
    await DatabaseRepository.instance.database;
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();

    super.dispose();
  }

  bool isExpanded = false;

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  Future<List<Item>> getAllItmes() async {
    return await DatabaseRepository.instance.getAllItems();
  }

  List<Item> items = [];
  void updateItems() async {
    await DatabaseRepository.instance.getAllItems().then((value) {
      setState(() {
        items = value;
        groupItemsByDate();
      });
    }).catchError((e) => debugPrint(e.toString()));
  }

  double totalExpenses() {
    final res = items.isEmpty
        ? 0.0
        : items.map((e) => e.price).reduce((value, element) => value + element);
    return double.parse(((res * 1000).roundToDouble() / 1000).toStringAsFixed(3));
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
      debugPrint(itemsByDate.toString());
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
      body: _islocked
          ? showLockScreen()
          : Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.all(8.0),
                  child: Text(
                    "Total expenses",
                    // style: TextStyle(
                    //   fontSize: 24,
                    //   fontWeight: FontWeight.bold,
                    // ),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Center(
                  child: SizedBox(
                    height: 150,
                    child: Center(
                      child: Text(
                        // '${totalExpenses().toString()} DT',
                        totalExpenses().toString(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
                          final x = await openDialog2();
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
                      if (isSelected != -1)
                        Container(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          alignment: Alignment.bottomCenter,
                          child: TapRegion(
                            onTapOutside: (event) {
                              setState(() {
                                isSelected = -1;
                              });
                            },
                            child: Container(
                              height: 70,
                              child: Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Container(
                                      child: ElevatedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: CircleBorder(),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Column(
                                            children: [
                                              Icon(Icons.delete),
                                              Text('Delete')
                                            ],
                                          ),
                                        ),
                                        onPressed: () async {
                                          debugPrint("DELTED ????");
                                          await DatabaseRepository.instance
                                              .deleteItem(
                                                  items[isSelected].id!);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Transaction deleted !')),
                                          );
                                          setState(() {
                                            items = items
                                                .where((item) =>
                                                    item.id !=
                                                    items[isSelected].id)
                                                .toList();
                                            isSelected = -1;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  // This is for the EDIT button
                                  // Flexible(
                                  //   fit: FlexFit.tight,
                                  //   child: Container(
                                  //     child: IconButton(
                                  //       style: ButtonStyle(
                                  //         shape: MaterialStateProperty.all<
                                  //             RoundedRectangleBorder>(
                                  //           const RoundedRectangleBorder(
                                  //             borderRadius: BorderRadius.zero,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       icon: const Column(
                                  //         children: [Icon(Icons.edit), Text('Edit')],
                                  //       ),
                                  //       onPressed: () {

                                  //       },
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
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
    return Container(
      color: isSelected == idx ? Colors.grey[300] : null,
      child: ListTile(
        selected: isSelected == idx,
        onLongPress: () {
          setState(() {
            isSelected = idx;
          });
        },
        leading: Icon(
          items[idx].isCredit() ? Icons.shopping_bag : Icons.paid,
          color: const Color.fromARGB(255, 66, 133,
              244), //Theme.of(context).colorScheme.onSurfaceVariant
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
            color: items[idx].isCredit()
                ? Color.fromARGB(255, 219, 68, 55)
                : const Color.fromARGB(255, 15, 157, 88),
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              items[idx].title,
              style: const TextStyle(
                fontSize: 21,
              ),
            ),
            // Row(
            //   children: [
            //     Text(
            //       '${items[idx].price.toString()} DT',
            //       style: TextStyle(
            //         fontSize: 18,
            //         color: items[idx].isCredit()
            //             ? const Color.fromARGB(255, 219, 68, 55)
            //             : const Color.fromARGB(255, 15, 157, 88),
            //       ),
            //     )
            //   ],
            // )
          ],
        ),
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
                      debugPrint(value.length.toString());
                      final x = await DatabaseRepository.instance.readPin();
                      debugPrint(x.toString());
                      if (x.isEmpty) {
                        value = value.isEmpty ? "-1" : value;
                        await DatabaseRepository.instance.insertPin(pin: value);
                        final xx = await DatabaseRepository.instance.readPin();
                        debugPrint(xx.toString());
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
      );
      Navigator.of(context).pop(thisItem);
    }
  }

  final _formKey = GlobalKey<FormState>();
  Future<Item?> openDialog2() {
    titleController.text = '';
    priceController.text = '';
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                child: Text("New transaction"),
              ),
              insetPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.all(24.0),
              content: SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Form(
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
                                    constraints: const BoxConstraints(maxWidth: 285),
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
                                                AutocompleteHighlightedOption
                                                        .of(context) ==
                                                    index;
                                            if (highlight) {
                                              SchedulerBinding.instance
                                                  .addPostFrameCallback(
                                                      (Duration timeStamp) {
                                                Scrollable.ensureVisible(
                                                    context,
                                                    alignment: 0.5);
                                              });
                                            }
                                            return Container(
                                              color: highlight
                                                  ? Theme.of(context).focusColor
                                                  : null,
                                              padding:
                                                  const EdgeInsets.all(16.0),
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
                                return x.toSet().where(
                                    (e) => e.toLowerCase().startsWith(textEditingValue.text.toLowerCase()));
                              }
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController
                                    fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted) {
                                  fieldTextEditingController.addListener(() {
                                    titleController.text = fieldTextEditingController.text;
                                  });
                              return TextFormField(
                                focusNode: fieldFocusNode,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  titleController.text = titleController.text.trim();
                                  return null;
                                },
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: fieldTextEditingController,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  alignLabelWithHint: true,
                                  labelText: 'Item',
                                  labelStyle: TextStyle(
                                    fontSize: 18,
                                  ),
                                  // border: OutlineInputBorder(),
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
                              RegExp pattern =
                                  RegExp(r'^[0-9][0-9]*\.?[0-9]*$');
                              if (!pattern.hasMatch(value)) {
                                return 'Please insert only numbers';
                              }
                              return null;
                            },
                            controller: priceController,
                            decoration: const InputDecoration(
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
                        )
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: const ButtonStyle(
                        padding: MaterialStatePropertyAll(
                            EdgeInsets.only(left: 0.0)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Transaction saved !')),
                              );
                              final thisItem = Item(
                                price: double.parse(priceController.text),
                                title: titleController.text,
                                timestamp:
                                    DateTime.now().millisecondsSinceEpoch,
                              );
                              Navigator.of(context).pop(thisItem);
                            }
                          },
                          child: const Text(
                            "Debit",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        TextButton(
                          style: const ButtonStyle(
                            padding: MaterialStatePropertyAll(
                              EdgeInsets.only(right: 0.0),
                            ),
                          ),
                          onPressed: () {
                            _credit();
                          },
                          child: const Text(
                            "Credit",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ));
  }
}
