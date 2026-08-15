// lib/widgets/confirm_dialog.dart
import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(BuildContext context, {
  required String title,
  required String message,
  String confirmText = '确认',
  String cancelText = '取消',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}