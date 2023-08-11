import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/constants.dart';

/// Success Dialog
void successDialog(
  BuildContext context, {
  required String message,
  Widget? icon,
  String? title,
  String? negativeText,
  VoidCallback? negativeAction,
  String? positiveText,
  VoidCallback? positiveAction,
}) {
  _buildDialog(context, "success",
      message: message,
      icon: icon,
      title: title,
      negativeText: negativeText,
      negativeAction: negativeAction,
      positiveText: positiveText,
      positiveAction: positiveAction);
}

/// Error Dialog
void errorDialog(
  BuildContext context, {
  required String message,
  Widget? icon,
  String? title,
  String? negativeText,
  VoidCallback? negativeAction,
  String? positiveText,
  VoidCallback? positiveAction,
}) {
  _buildDialog(context, "error",
      message: message,
      icon: icon,
      title: title,
      negativeText: negativeText,
      negativeAction: negativeAction,
      positiveText: positiveText,
      positiveAction: positiveAction);
}

/// Confirm Dialog
void confirmDialog(
  BuildContext context, {
  required String message,
  Widget? icon,
  String? title,
  String? negativeText,
  VoidCallback? negativeAction,
  String? positiveText,
  VoidCallback? positiveAction,
}) {
  _buildDialog(context, "confirm",
      icon: icon,
      title: title,
      message: message,
      negativeText: negativeText,
      negativeAction: negativeAction,
      positiveText: positiveText,
      positiveAction: positiveAction);
}

/// Confirm Dialog
void infoDialog(
  BuildContext context, {
  required String message,
  Widget? icon,
  String? title,
  String? negativeText,
  VoidCallback? negativeAction,
  String? positiveText,
  VoidCallback? positiveAction,
}) {
  _buildDialog(context, "info",
      icon: icon,
      title: title,
      message: message,
      negativeText: negativeText,
      negativeAction: negativeAction,
      positiveText: positiveText,
      positiveAction: positiveAction);
}

/// Build dialog
void _buildDialog(
  BuildContext context,
  String type, {
  required Widget? icon,
  required String? title,
  required String message,
  required String? negativeText,
  required VoidCallback? negativeAction,
  required String? positiveText,
  required VoidCallback? positiveAction,
}) {
  final i18n = AppLocalizations.of(context);
  late Widget icon0;
  late String title0;

  // Control type
  switch (type) {
    case "success":
      icon0 = icon ?? const Icon(Iconsax.tick_circle, color: APP_SUCCESS);
      title0 = title ?? i18n.translate("success");
      break;
    case "error":
      icon0 = icon ?? const Icon(Iconsax.flag, color: APP_ERROR);
      title0 = title ?? i18n.translate("error");
      break;
    case "confirm":
      icon0 = icon ?? const Icon(Iconsax.tick_square, color: APP_WARNING);
      title0 = title ?? i18n.translate("are_you_sure");
      break;

    case "info":
      icon0 = icon ?? const Icon(Iconsax.information, color: APP_INFO);
      title0 = title ?? i18n.translate("information");
      break;
  }

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              icon0,
              const SizedBox(width: 10),
              Expanded(
                  child: Text(title0, style: const TextStyle(fontSize: 20)))
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            /// Negative button
            negativeAction == null
                ? const SizedBox(width: 0, height: 0)
                : TextButton(
                    onPressed: negativeAction,
                    child: Text(negativeText ?? i18n.translate("CANCEL"),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey))),

            /// Positive button
            TextButton(
                onPressed: positiveAction ?? () => Navigator.of(context).pop(),
                child: Text(
                  positiveText ?? i18n.translate("OK"),
                )),
          ],
        );
      });
}
