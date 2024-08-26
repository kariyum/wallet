import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walletapp/models/item.dart';

import '../app_state/config.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double counter = -500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedCount(
          count: counter,
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          setState(() {
            counter += 100;
          });
        },
        child: const Text("Add"),
      ),
    );
  }
}

class AnimatedCount extends ImplicitlyAnimatedWidget {
  final double count;
  const AnimatedCount({
    super.key,
    required this.count,
    super.duration = const Duration(milliseconds: 500),
    super.curve = Curves.easeOutCubic,
  });

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() {
    return _AnimatedCountState();
  }
}

class _AnimatedCountState extends AnimatedWidgetBaseState<AnimatedCount> {
  late IntTween _count;
  late Tween<double> _double;
  bool atInit = false;
  @override
  void initState() {
    // TODO: implement initState
    // _count = IntTween(
    //   begin: 0,
    //   end: widget.count,
    // );
    _double = Tween<double>(
      begin: widget.count.toDouble(),
      end: widget.count.toDouble(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Config>(
      builder: (context, config, child) {
        final currencyString = config.currencyToString(config.currency);
        return Text("${_double.evaluate(animation).format()} $currencyString", style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),);
      }
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    // _count = visitor(
    //   _count,
    //   widget.count,
    //   (dynamic value) => IntTween(begin: value),
    // ) as IntTween;
    _double = visitor(
      _double,
      widget.count.toDouble(),
          (dynamic value) => Tween<double>(begin: value),
    ) as Tween<double>;
  }
}
