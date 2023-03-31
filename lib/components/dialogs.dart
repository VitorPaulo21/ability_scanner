import 'package:flutter/material.dart';

class Dialogs {
  static Future<bool?> errorDialog(
      context, String title, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning,
                color: Colors.red,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(child: Text(message)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
                child: const Text("Ok"))
          ],
        );
      },
    );
  }

  static Future<bool?> infoDialog(context, String title, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
              const SizedBox(
                width: 10,
              ),
              Expanded(child: Text(message)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
                child: const Text("Ok"))
          ],
        );
      },
    );
  }

  static Future<bool?> dialogWithOptions(
      context, String title, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
                child: const Text("Sim")),
            TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(false);
                },
                child: const Text("Não")),
          ],
        );
      },
    );
  }
}
