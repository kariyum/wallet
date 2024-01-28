import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:walletapp/models/item.dart';

class ItemInputDialog extends StatefulWidget {
  final GlobalKey<FormState> formkey;
  final List<Item> items;
  final TextEditingController titleController, priceController, notesController;
  const ItemInputDialog({
      super.key,
      required this.formkey,
      required this.notesController,
      required this.titleController,
      required this.priceController,
      required this.items,
      }
    );

  @override
  State<ItemInputDialog> createState() => _ItemInputDialogState();
}

class _ItemInputDialogState extends State<ItemInputDialog> {
  
  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = widget.formkey;
    TextEditingController titleController = widget.titleController;
    TextEditingController priceController = widget.priceController;
    TextEditingController notesController = widget.notesController;
    List<Item> items = widget.items;

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
      bottomNavigationBar: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          debitButton(titleController, priceController, notesController, formKey), 
          creditButton(formKey, priceController, titleController, notesController)
          ],
      ),
      body: dialogBody(formKey, items, titleController, priceController, notesController),
    );
  }

  Widget itemInputTitle(List<Item> items, TextEditingController titleController) {
    return Padding(
      padding: const EdgeInsets.only(left: 7.0, right: 8.0),
      child: Autocomplete(
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 3.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 284),
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
                            AutocompleteHighlightedOption.of(context) == index;
                        if (highlight) {
                          SchedulerBinding.instance
                              .addPostFrameCallback((Duration timeStamp) {
                            Scrollable.ensureVisible(context, alignment: -1.5);
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
          final x = items.map((e) => e.title).toList();
          if (textEditingValue.text == '') {
            return const Iterable<String>.empty();
          } else {
            return x.toSet().where((e) => e
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
            autofocus: true,
            decoration: const InputDecoration(
              alignLabelWithHint: true,
              labelText: 'Item',
              labelStyle: TextStyle(
                fontSize: 17,
              ),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          );
        },
      ),
    );
  }

  Widget priceInputField(GlobalKey<FormState> formKey, TextEditingController priceController, TextEditingController titleController, TextEditingController notesController){
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: TextFormField(
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

  Widget dialogBody(GlobalKey<FormState> formKey, List<Item> items, TextEditingController titleController, TextEditingController priceController, TextEditingController notesController){
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Column(
        children: [
          Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                itemInputTitle(items, titleController),
                const Padding(padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8.0)),
                priceInputField(formKey, priceController, titleController, notesController),
                const Padding(padding: EdgeInsets.only(top: 16.0)),
                textArea(notesController),
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
    );
  }

  Widget debitButton(TextEditingController titleController, TextEditingController priceController, TextEditingController notesController, GlobalKey<FormState> formKey) {
    return Flexible(
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
          if (formKey.currentState!.validate()) {
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
    );
  }

  
  Widget creditButton(GlobalKey<FormState> formKey, TextEditingController priceController, TextEditingController titleController, TextEditingController notesController ) {
    return Flexible(
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

  void _credit(GlobalKey<FormState> formKey, TextEditingController priceController, TextEditingController titleController, TextEditingController notesController) {
    if (formKey.currentState!.validate()) {
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
      );
      Navigator.of(context).pop(thisItem);
    }
  }
}
