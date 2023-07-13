import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

var items = <Item>[];

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
    super.initState();
    myController = TextEditingController();
    myController.text = '';
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

  @override
  Widget build(BuildContext context) {
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
              debugPrint("the price was $price");
              items.add(Item(e, price));
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
        backgroundColor: Theme.of(context).colorScheme.surface ,//Theme.of(context).colorScheme.primaryContainer,
        primary: true,
        
        title: const Center(
          child: Text("Wallet"),
        ),
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
                      "100 DT",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Text(
                      "Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: ListView.builder(
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
                            '${items[idx].item}',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text('${items[idx].price}',
                              style: TextStyle(
                                fontSize: 18,
                              )),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                child: TapRegion(
                  onTapOutside: (tap) {
                    setState(() {
                      debugPrint('isExpanded: $isExpanded');
                      debugPrint('isDialogOpen: $isDialogOpen');
                      isExpanded = isExpanded && isDialogOpen;
                      debugPrint("TAPPED OUTSIDE");
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isExpanded)
                        SizedBox(
                          width: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: l,
                          ),
                        ),
                      FloatingActionButton(
                        onPressed: toggleExpansion,
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

class FloatingButtonExpansion extends StatefulWidget {
  @override
  _FloatingButtonExpansionState createState() =>
      _FloatingButtonExpansionState();
}

class _FloatingButtonExpansionState extends State<FloatingButtonExpansion> {
  late TextEditingController myController;
  bool isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    myController = TextEditingController();
    myController.text = '';
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

  @override
  Widget build(BuildContext context) {
    List<Widget> l = ["Groceries", "Car gas", "Others", "Fun"]
        .map(
          (e) => ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0))),
            onPressed: () async {
              final price = await openDialog();
              debugPrint("the price was $price");
              items.add(Item(e, price));
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
    return TapRegion(
      onTapOutside: (tap) {
        setState(() {
          debugPrint('isExpanded: $isExpanded');
          debugPrint('isDialogOpen: $isDialogOpen');
          isExpanded = isExpanded && isDialogOpen;
          debugPrint("TAPPED OUTSIDE");
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isExpanded)
            SizedBox(
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: l,
              ),
            ),

          // Flexible(
          //   child: SizedBox(
          //     width: 200,
          //     child: ListView.builder(
          //         shrinkWrap: true,
          //         itemCount: 4,
          //         itemBuilder: (BuildContext context, int idx) {
          //           return Container(
          //             color: Colors.white,
          //             // child: ListTile(
          //             //   title: Text('item $idx'),
          //             //   onLongPress: (){},
          //             //   onTap: (){
          //             //     debugPrint('item $idx');
          //             //   },
          //             // ),
          //             child: ElevatedButton(
          //               style: ElevatedButton.styleFrom(
          //                   shape: const RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.all(Radius.zero),
          //               )),
          //               child: Text("yoo"),
          //               onPressed: () {},
          //             ),
          //           );
          //         }),
          //   ),
          // ),
          FloatingActionButton(
            onPressed: toggleExpansion,
            child: Icon(Icons.add),
          ),
        ],
      ),
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

class Item {
  String item;
  String? price;
  Item(this.item, this.price);
}

class ExpensesList extends StatefulWidget {
  const ExpensesList({super.key});

  @override
  State<ExpensesList> createState() => ExpensesListState();
}

class ExpensesListState extends State<ExpensesList> {
  var tiles = items
      .map((e) => {
            ListTile(
              title: Text(
                '${e.item} ${e.price}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
          })
      .toList();
  @override
  Widget build(BuildContext context) {
    return items.length != 0
        ? Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (BuildContext context, int idx) {
                return ListTile(
                  title: Text(
                    '${items[idx].item} ${items[idx].price}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                );
              },
            ),
          )
        : Text("Emty list");
  }
}
