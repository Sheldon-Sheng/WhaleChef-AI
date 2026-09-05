// lib/widgets/confirm_dialog.dart
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
}) {
  final l10n = AppLocalizations.of(context);
  final confirm = confirmText ?? l10n.confirm;
  final cancel = cancelText ?? l10n.cancel;
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirm),
        ),
      ],
    ),
  );
}
