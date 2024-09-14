import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:walletapp/app_state/items_model.dart';
import 'package:walletapp/app_state/theme_provider.dart';
import 'package:walletapp/models/item.dart';

import 'custom_checkbox.dart';

class ItemInputDialog extends StatefulWidget {
  final GlobalKey<FormState> formkey;
  final List<Item> items;
  final TextEditingController titleController,
      priceController,
      notesController,
      dateController;
  final Item? defaultItem;

  const ItemInputDialog({
    super.key,
    this.defaultItem,
    required this.formkey,
    required this.notesController,
    required this.titleController,
    required this.priceController,
    required this.dateController,
    required this.items,
  });

  @override
  State<ItemInputDialog> createState() => _ItemInputDialogState();
}

class _ItemInputDialogState extends State<ItemInputDialog> {
  DateTime? pickedDate;
  TimeOfDay? pickedTime;
  bool isPaid = true;

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = widget.formkey;
    TextEditingController titleController = widget.titleController;
    TextEditingController priceController = widget.priceController;
    TextEditingController notesController = widget.notesController;
    TextEditingController dateController = widget.dateController;
    List<Item> items = widget.items;
    final Item? item = widget.defaultItem;
    if (item != null) {
      titleController.text = item.title;
      priceController.text = item.price.abs().toString();
      notesController.text = item.notes != null ? item.notes! : "";
    }
    final ThemeProvider themeProvider = context.read<ThemeProvider>();
    return Scaffold(
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
      bottomNavigationBar: SafeArea(
        child: Container(
          color: () {
            if (themeProvider.isDarkMode()) {
              return Color.fromRGBO(232, 240, 247, 0.1);
            }
            return Color.fromRGBO(232, 240, 247, 0.5);
          }(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              debitButton(
                  titleController, priceController, notesController, formKey),
              const SizedBox(
                height: 40,
                child: VerticalDivider(width: 1, ),
              ),
              creditButton(
                  formKey, priceController, titleController, notesController)
            ],
          ),
        ),
      ),
      body: dialogBody(formKey, items, titleController, priceController,
          notesController, dateController),
    );
  }

  Widget titleInputField(
      List<Item> items, TextEditingController titleController) {
    return Padding(
      padding: const EdgeInsets.only(left: 7.0, right: 8.0),
      child: LayoutBuilder(
        builder: (_, BoxConstraints constraints) => Autocomplete(
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 3.0,
                child: ConstrainedBox(
                  constraints: constraints,
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
                        child: Builder(builder: (BuildContext context) {
                          final bool highlight =
                              AutocompleteHighlightedOption.of(context) ==
                                  index;
                          if (highlight) {
                            SchedulerBinding.instance
                                .addPostFrameCallback((Duration timeStamp) {
                              Scrollable.ensureVisible(context,
                                  alignment: -1.5);
                            });
                          }
                          return Container(
                            color:
                                highlight ? Theme.of(context).focusColor : null,
                            padding: const EdgeInsets.all(15.0),
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
            final x = items.map((e) => e.title).toSet();
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            } else {
              return x.where((e) => e
                  .toLowerCase()
                  .startsWith(textEditingValue.text.toLowerCase()));
            }
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController fieldTextEditingController,
              FocusNode fieldFocusNode,
              VoidCallback onFieldSubmitted) {
            fieldTextEditingController.addListener(() {
              titleController.text = fieldTextEditingController.text;
            });
            fieldTextEditingController.text = titleController.text;
            return TextFormField(
              focusNode: fieldFocusNode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                titleController.text = titleController.text.trim();
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
              controller: fieldTextEditingController,
              autofocus: widget.defaultItem == null,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Item',
                labelStyle: TextStyle(
                  fontSize: 17,
                ),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) {
                fieldFocusNode.unfocus();
                FocusScope.of(context).requestFocus(priceInputFieldFocusNode);
              },
            );
          },
        ),
      ),
    );
  }

  final priceInputFieldFocusNode = FocusNode();
  Widget priceInputField(
      GlobalKey<FormState> formKey,
      TextEditingController priceController,
      TextEditingController titleController,
      TextEditingController notesController) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: TextFormField(
        focusNode: priceInputFieldFocusNode,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a number';
          }
          priceController.text = priceController.text.replaceAll(',', '.');
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
          _credit(formKey, priceController, titleController, notesController);
        },
      ),
    );
  }

  Widget textArea(TextEditingController notesController) {
    return Padding(
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
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final pickedDate = showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    return pickedDate;
  }

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    final pickedTime = showTimePicker(
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? Container(),
        );
      },
      context: context,
      initialTime: TimeOfDay.now(),
    );
    return pickedTime;
  }

  Widget dialogBody(
      GlobalKey<FormState> formKey,
      List<Item> items,
      TextEditingController titleController,
      TextEditingController priceController,
      TextEditingController notesController,
      TextEditingController dateController) {
    final DateTime? defaultDateTime = widget.defaultItem != null
        ? DateTime.fromMillisecondsSinceEpoch(widget.defaultItem!.timestamp)
        : null;
    final DateTime dateTime = defaultDateTime ?? DateTime.now();
    TextEditingController timeController = TextEditingController(
        text:
            "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}");

    dateController.text =
        "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  titleInputField(items, titleController),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8.0)),
                  priceInputField(formKey, priceController, titleController,
                      notesController),
                  const Padding(padding: EdgeInsets.only(top: 16.0)),
                  textArea(notesController),
                  // TimePickerDialog(initialTime: TimeOfDay(hour: 1, minute: 1)),

                  // if (widget.defaultItem != null)
                    Row(
                      children: [
                        Flexible(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: TextField(
                              controller: dateController,
                              onTap: () async {
                                selectDateField(dateController);
                              },
                              readOnly: true,
                              canRequestFocus: false,
                              showCursor: false,
                              autofocus: false,
                              decoration: InputDecoration(
                                alignLabelWithHint: true,
                                labelText: 'Date',
                                labelStyle: const TextStyle(
                                  fontSize: 17,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.date_range,
                                    ),
                                    onPressed: () async {
                                      selectDateField(dateController);
                                    },
                                  ),
                                ),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: TextField(
                              controller: timeController,
                              onTap: () async {
                                selectTimeField(timeController);
                              },
                              canRequestFocus: false,
                              showCursor: false,
                              autofocus: false,
                              readOnly: true,
                              decoration: InputDecoration(
                                alignLabelWithHint: true,
                                labelText: 'Time',
                                labelStyle: const TextStyle(
                                  fontSize: 17,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.access_time_outlined,
                                    ),
                                    onPressed: () async {
                                      selectTimeField(timeController);
                                    },
                                  ),
                                ),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: CustomCheckBox(
                      defaultValue: widget.defaultItem?.paid,
                      onChanged: (bool value) {
                        isPaid = !value;
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void selectDateField(TextEditingController dateController) async {
    final selectedDate = await _selectDate(context);
    pickedDate = selectedDate;
    if (pickedDate != null) {
      dateController.text =
          "${pickedDate!.day.toString().padLeft(2, '0')}/${pickedDate!.month.toString().padLeft(2, '0')}/${pickedDate!.year}";
    }
  }

  void selectTimeField(TextEditingController timeController) async {
    final selectedTime = await _selectTime(context);
    pickedTime = selectedTime;
    if (pickedTime != null) {
      timeController.text =
          "${pickedTime!.hour.toString().padLeft(2, '0')}:${pickedTime!.minute.toString().padLeft(2, '0')}";
    }
  }

  DateTime getDate() {
    DateTime date = DateTime.now();
    if (pickedDate != null) {
      date = date.copyWith(
          year: pickedDate!.year,
          month: pickedDate!.month,
          day: pickedDate!.day);
    } else if (widget.defaultItem != null) {
      final defaultDate =
          DateTime.fromMillisecondsSinceEpoch(widget.defaultItem!.timestamp);
      date = date.copyWith(
          year: defaultDate.year,
          month: defaultDate.month,
          day: defaultDate.day);
    }
    if (pickedTime != null) {
      date = date.copyWith(hour: pickedTime!.hour, minute: pickedTime!.minute);
    } else if (widget.defaultItem != null) {
      final defaultDate =
          DateTime.fromMillisecondsSinceEpoch(widget.defaultItem!.timestamp);
      date = date.copyWith(hour: defaultDate.hour, minute: defaultDate.minute);
    }
    return date;
  }

  Widget debitButton(
      TextEditingController titleController,
      TextEditingController priceController,
      TextEditingController notesController,
      GlobalKey<FormState> formKey) {
    return Flexible(
      fit: FlexFit.tight,
      child: TextButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
        onPressed: () {
          if (formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction saved !')),
            );
            final thisItem = Item(
              id: widget.defaultItem?.id,
              price: double.parse(priceController.text),
              title: titleController.text,
              timestamp: getDate().millisecondsSinceEpoch,
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
    );
  }

  Widget creditButton(
      GlobalKey<FormState> formKey,
      TextEditingController priceController,
      TextEditingController titleController,
      TextEditingController notesController) {
    return Flexible(
      fit: FlexFit.tight,
      child: TextButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
        onPressed: () {
          _credit(formKey, priceController, titleController, notesController);
        },
        child: const Text(
          "Credit",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  void _credit(
      GlobalKey<FormState> formKey,
      TextEditingController priceController,
      TextEditingController titleController,
      TextEditingController notesController) {
    if (formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction saved !')),
      );
      final thisItem = Item(
        id: widget.defaultItem?.id,
        price: 0 - double.parse(priceController.text),
        title: titleController.text,
        timestamp: getDate().millisecondsSinceEpoch,
        notes: notesController.text,
        paid: isPaid ? 1 : 0,
      );
      debugPrint("writing this item ${thisItem}");
      Navigator.of(context).pop(thisItem);
    }
  }
}
