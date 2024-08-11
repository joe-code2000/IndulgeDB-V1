import 'package:flutter/material.dart';

void goToPage({
  required BuildContext context,
  required Widget page,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return page;
      },
    ),
  );
}

Future<void> showShouldAlertDialog({
  required BuildContext context,
  required void Function(bool res) setResults,
  Widget? title,
  Widget? content,
}) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: title,
        content: content,
        actions: [
          TextButton(
            onPressed: () {
              setResults(true);
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
          TextButton(
            onPressed: () {
              setResults(false);
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );
}
