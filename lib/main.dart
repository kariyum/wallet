import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart' as p;

import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class Item {
  final int? id;
  final String title;
  final double price;
  final int timestamp;

  const Item({
    this.id,
    required this.title,
    required this.price,
    required this.timestamp,
  });

  factory Item.fromJson(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      price: map['price'],
      timestamp: map['timestamp'],
      title: map['title'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'price': price, 'timestamp': timestamp};
  }

  @override
  String toString() {
    return 'Item(id: $id, title: $title, price: $price, timestamp: $timestamp)';
  }

  Future<void> persist() async {
    await DatabaseRepository.instance.insert(item: this);
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
  }

  Future<void> insert({required Item item}) async {
    try {
      final db = await instance.database;
      await db.insert('items', item.toMap());
      debugPrint('inserted');
    } catch (e) {
      debugPrint(e.toString());
    }
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
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 29, 123, 177)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController myController;
  bool isDialogOpen = false;

  @override
  void initState() {
    initDb();
    super.initState();
    updateItems();
    myController = TextEditingController();
    myController.text = '';
  }

  Future<void> deleteDatabase(String path) =>
      databaseFactory.deleteDatabase(path);

  void initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'wallet.db');
    // await deleteDatabase(path);
    await DatabaseRepository.instance.database;
  }

  @override
  void dispose() {
    myController.dispose();
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
      });
    }).catchError((e) => debugPrint(e.toString()));
  }

  double totalExpenses() {
    final res = items.isEmpty
        ? 0.0
        : items.map((e) => e.price).reduce((value, element) => value + element);
    return res;
  }

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    debugPrint("rebuilding");
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent));

    List<Widget> l = ["Groceries", "Car gas", "Others", "Fun"]
        .map(
          (e) => ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: () async {
              final price = await openDialog();
              final cost = price == null ? "0" : price.toString();
              debugPrint("the price was $cost");
              // items.add(Item(e, price));
              Item(
                      price: double.parse(cost),
                      title: e,
                      timestamp: DateTime.now().millisecondsSinceEpoch)
                  .persist();
              updateItems();
              final toPrint = await DatabaseRepository.instance.getAllItems();
              debugPrint(toPrint.length.toString());
              isDialogOpen = false;
              setState(() {
                debugPrint("EXPANDING");
              });
            },
            child: Row(
              children: [
                Text(e),
              ],
            ),
          ),
        )
        .toList();

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
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.all(8.0),
                child: const Text(
                  "Total expenses",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  height: 150,
                  child: Center(
                    child: Text(
                      // '${totalExpenses().toString()} DT',
                      totalExpenses().toString(),
                      style: TextStyle(
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
                    margin: const EdgeInsets.all(16.0),
                    child: Text(
                      "Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add),
                    ),
                  )
                ],
              ),
              Flexible(
                child: ListView.separated(
                  controller: _scrollController,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int idx) {
                    return ListTile(
                      leading: Text("⨀"),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            items[idx].title,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            items[idx].price.toString(),
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '04/05',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     Container(
          //       margin: const EdgeInsets.all(20),
          //       child: TapRegion(
          //         onTapOutside: (tap) {
          //           // setState(() {
          //           //   debugPrint('isExpanded: $isExpanded');
          //           //   debugPrint('isDialogOpen: $isDialogOpen');
          //           //   isExpanded = isExpanded && isDialogOpen;
          //           //   debugPrint("TAPPED OUTSIDE");
          //           // });
          //         },
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.end,
          //           crossAxisAlignment: CrossAxisAlignment.end,
          //           children: [
          //             if (isExpanded)
          //               SizedBox(
          //                 width: 200,
          //                 child: Column(
          //                   mainAxisAlignment: MainAxisAlignment.end,
          //                   crossAxisAlignment: CrossAxisAlignment.stretch,
          //                   children: l,
          //                 ),
          //               ),
          //             FloatingActionButton(
          //               onPressed: toggleExpansion,
          //               child: Icon(Icons.add),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),

      // floatingActionButton:
      //     FloatingButtonExpansion(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<String?> openDialog() {
    isDialogOpen = true;
    myController.text = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        content: TextFormField(
          controller: myController,
          decoration: InputDecoration(
            hintText: 'Price',
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) {
            Navigator.of(context).pop(myController.text);
            isExpanded = false;
          },
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () {
        //       debugPrint("ok");
        //       Navigator.of(context).pop(myController.text);
        //     },
        //     child: Text('OK'),
        //   ),
        // ],
      ),
    );
  }
}

// class FloatingButtonExpansion extends StatefulWidget {
//   @override
//   _FloatingButtonExpansionState createState() =>
//       _FloatingButtonExpansionState();
// }

// class _FloatingButtonExpansionState extends State<FloatingButtonExpansion> {
//   late TextEditingController myController;
//   bool isDialogOpen = false;

//   @override
//   void initState() {
//     super.initState();
//     myController = TextEditingController();
//     myController.text = '';
//   }

//   @override
//   void dispose() {
//     myController.dispose();
//     super.dispose();
//   }

//   bool isExpanded = false;

//   void toggleExpansion() {
//     setState(() {
//       isExpanded = !isExpanded;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<Widget> l = ["Groceries", "Car gas", "Others", "Fun"]
//         .map(
//           (e) => ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.0))),
//             onPressed: () async {
//               final price = await openDialog();
//               debugPrint("the price was $price");
//               final cost = price == null ? "0" : price.toString();
//               Item(
//                       price: double.parse(cost.toString()),
//                       title: 'item 1',
//                       timestamp: DateTime.now().millisecondsSinceEpoch)
//                   .persist();

//               // items.add(Item(e, price));
//               isDialogOpen = false;
//               setState(() {
//                 debugPrint("EXPANDING");
//               });
//             },
//             child: Row(
//               children: [
//                 Text(e),
//               ],
//             ),
//           ),
//         )
//         .toList();
//     return TapRegion(
//       onTapOutside: (tap) {
//         setState(() {
//           debugPrint('isExpanded: $isExpanded');
//           debugPrint('isDialogOpen: $isDialogOpen');
//           isExpanded = isExpanded && isDialogOpen;
//           debugPrint("TAPPED OUTSIDE");
//         });
//       },
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (isExpanded)
//             SizedBox(
//               width: 200,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: l,
//               ),
//             ),

//           // Flexible(
//           //   child: SizedBox(
//           //     width: 200,
//           //     child: ListView.builder(
//           //         shrinkWrap: true,
//           //         itemCount: 4,
//           //         itemBuilder: (BuildContext context, int idx) {
//           //           return Container(
//           //             color: Colors.white,
//           //             // child: ListTile(
//           //             //   title: Text('item $idx'),
//           //             //   onLongPress: (){},
//           //             //   onTap: (){
//           //             //     debugPrint('item $idx');
//           //             //   },
//           //             // ),
//           //             child: ElevatedButton(
//           //               style: ElevatedButton.styleFrom(
//           //                   shape: const RoundedRectangleBorder(
//           //                 borderRadius: BorderRadius.all(Radius.zero),
//           //               )),
//           //               child: Text("yoo"),
//           //               onPressed: () {},
//           //             ),
//           //           );
//           //         }),
//           //   ),
//           // ),
//           FloatingActionButton(
//             onPressed: toggleExpansion,
//             child: Icon(Icons.add),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<String?> openDialog() {
//     isDialogOpen = true;
//     myController.text = '';
//     return showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         content: TextFormField(
//           controller: myController,
//           decoration: InputDecoration(
//             hintText: 'Price',
//           ),
//           keyboardType: TextInputType.number,
//           autofocus: true,
//           textInputAction: TextInputAction.done,
//           onFieldSubmitted: (value) {
//             Navigator.of(context).pop(myController.text);
//             isExpanded = false;
//           },
//         ),
//         // actions: [
//         //   TextButton(
//         //     onPressed: () {
//         //       debugPrint("ok");
//         //       Navigator.of(context).pop(myController.text);
//         //     },
//         //     child: Text('OK'),
//         //   ),
//         // ],
//       ),
//     );
//   }
// }

// class ExpensesList extends StatefulWidget {
//   const ExpensesList({super.key});

//   @override
//   State<ExpensesList> createState() => ExpensesListState();
// }

// class ExpensesListState extends State<ExpensesList> {
//   var tiles = items
//       .map((e) => {
//             ListTile(
//               title: Text(
//                 'xxx',
//                 style: TextStyle(
//                   fontSize: 18,
//                 ),
//               ),
//             )
//           })
//       .toList();
//   @override
//   Widget build(BuildContext context) {
//     return items.length != 0
//         ? Flexible(
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: items.length,
//               itemBuilder: (BuildContext context, int idx) {
//                 return ListTile(
//                   title: Text(
//                     'aaa',
//                     style: TextStyle(
//                       fontSize: 18,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           )
//         : Text("Emty list");
//   }
// }
