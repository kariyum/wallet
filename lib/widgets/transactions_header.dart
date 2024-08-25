import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:walletapp/app_state/appbar_progress_indicator.dart';

import '../app_state/items_model.dart';
import '../models/item.dart';
import '../services/database.dart';
import '../services/firebase.dart';

class TransactionsHeader extends StatelessWidget {
  final Firebase firebase;

  const TransactionsHeader({super.key, required this.firebase});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
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
                  onPressed: () async {
                    await onUpload(
                      context,
                      context.read<AppbarProgressIndicator>(),
                    );
                  },
                  icon: const Icon(Icons.upload),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    await onDownload(
                      context,
                      context.read<AppbarProgressIndicator>(),
                    );
                  },
                  icon: const Icon(Icons.download),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<String?> openDialogSync(BuildContext context) {
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
        content: Column(
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
    );
  }

  Future<void> saveAllItems(List<Item> items) {
    return DatabaseRepository.instance.saveAllItems(items);
  }

  Future<void> onUpload(
      BuildContext context, AppbarProgressIndicator loadingIndicator) async {
    loadingIndicator.start();
    try {
      final documentId = await firebase
          .uploadItems(Provider.of<ItemsModel>(context, listen: false).items);
      await Clipboard.setData(ClipboardData(text: documentId));
      loadingIndicator.stop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document id copied to clipboard!'),
          ),
        );
      }
    } catch (exception) {
      debugPrint("Uploading failed reason ${exception.toString()}");
      loadingIndicator.stop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploading failed, ${exception.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> onDownload(
      BuildContext context, AppbarProgressIndicator loadingIndicator) async {
    final futureValue = await openDialogSync(context);
    if (futureValue != null) {
      // downloading
      final futureData = firebase.downloadItems(futureValue);
      loadingIndicator.start();
      final data = await futureData;
      if (context.mounted) {
        Provider.of<ItemsModel>(context, listen: false).set(data);
      }
      await saveAllItems(data);
      loadingIndicator.stop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Items saved locally!'),
          ),
        );
      }
    }
  }
}
