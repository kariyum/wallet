import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ReactiveFloatingActionButton extends StatefulWidget {
  const ReactiveFloatingActionButton({
    super.key,
    required this.controller,
    required this.onPressed,
    required this.child,
    this.visibleOnPageIndex = 0,
    this.currentPageIndex = 0,
  });

  final ScrollController controller;
  final void Function()? onPressed;
  final Widget child;
  final int visibleOnPageIndex;
  final int currentPageIndex;
  @override
  State<ReactiveFloatingActionButton> createState() =>
      _ReactiveFloatingActionButtonState();
}

class _ReactiveFloatingActionButtonState
    extends State<ReactiveFloatingActionButton> {
  bool isVisable = true;
  bool _animationCompleted = false;

  @override
  void initState() {
    widget.controller.addListener(() {
      bool wasVisable = isVisable;
      isVisable = widget.controller.position.userScrollDirection ==
          ScrollDirection.forward;
      if (wasVisable != isVisable) {
        setState(() {
          isVisable = isVisable;
          _animationCompleted = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisable ? 1.0 : 0.0,
      duration: Durations.short3,
      curve: Curves.easeInOut,
      onEnd: () {
        setState(() {
          _animationCompleted = true;
        });
      },
      child: ((isVisable || !_animationCompleted) &&
              widget.visibleOnPageIndex == widget.currentPageIndex)
          ? FloatingActionButton(
              onPressed: widget.onPressed,
              child: widget.child,
            )
          : const SizedBox(),
    );
  }
}
