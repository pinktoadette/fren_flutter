import 'package:flutter/material.dart';
import 'package:machi_app/widgets/animations/loader.dart';

class ProgressDialog {
  final BuildContext context;
  bool isDismissible = true;

  // Local variables
  BuildContext? _dismissingContext;

  // Constructor
  ProgressDialog(this.context, {this.isDismissible = true});

  // Show progress dialog
  Future<bool> show(String message) async {
    try {
      showDialog<dynamic>(
        context: context,
        barrierDismissible: isDismissible,
        builder: (BuildContext context) {
          _dismissingContext = context; // Store the context
          return const SimpleDialog(
            elevation: 8.0,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: Frankloader(),
              )
            ],
          );
        },
      );
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint('show progress dialog() -> success');
      return true;
    } catch (err) {
      debugPrint('Exception while showing the progress dialog');
      debugPrint(err.toString());
      return false;
    }
  }

  // Hide progress dialog
  Future<bool> hide() async {
    try {
      Navigator.of(_dismissingContext!).pop();
      debugPrint('ProgressDialog dismissed');
      return Future.value(true);
    } catch (err) {
      debugPrint('Seems there is an issue hiding dialog');
      debugPrint(err.toString());
      return Future.value(false);
    }
  }
}
