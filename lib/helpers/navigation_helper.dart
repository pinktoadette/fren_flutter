import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/widgets/signin/signin_widget.dart';

class NavigationHelper {
  static void handleGoToPageOrLogin({
    required BuildContext context,
    required UserController userController,
    required void Function()
        navigateAction, // Function that performs the navigation
  }) async {
    try {
      if (userController.user == null) {
        showModalBottomSheet<void>(
          context: context,
          builder: (context) => FractionallySizedBox(
            heightFactor: 0.55,
            widthFactor: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: const SignInWidget(),
            ),
          ),
        );
      } else {
        // Perform the navigation action
        navigateAction();
      }
    } catch (error, stack) {
      debugPrint('An error when navigating : $error');
      await FirebaseCrashlytics.instance.recordError(error, stack,
          reason: 'Error occurred when navigating : ${error.toString()}',
          fatal: true);
    }
  }
}
