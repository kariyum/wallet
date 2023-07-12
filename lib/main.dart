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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
    List<ListTile> tiles = items.length != 0
        ? items
            .map((e) => {
                  ListTile(
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${e.item}',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                        Text('${e.price}',
                            style: TextStyle(
                              fontSize: 18,
                            ))
                      ],
                    ),
                  )
                })
            .toList()[0]
            .toList()
        : <ListTile>[
            ListTile(
              title: Text("List is empty"),
            )
          ].toList();
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
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Center(
                child: Text(
                  "100 DT",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Text(
                      "Details",
                      style: TextStyle(fontSize: 18),
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
                              ))
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
                margin: EdgeInsets.all(10),
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
