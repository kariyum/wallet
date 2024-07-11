import 'package:flutter/material.dart';
class CustomCheckBox extends StatefulWidget {
  final ValueChanged<bool> onChanged;
  final int? defaultValue;
  const CustomCheckBox({
    super.key,
    required this.onChanged,
    required this.defaultValue,
  });

  @override
  State<CustomCheckBox> createState() => CustomCheckBoxState();
}

class CustomCheckBoxState extends State<CustomCheckBox> {
  bool isChecked = false;
  @override
  void initState() {
    super.initState();
    int defaultCheck = widget.defaultValue ?? 1;
    isChecked = defaultCheck == 1 ? false : true;
  }
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
