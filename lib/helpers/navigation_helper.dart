import 'package:flutter/material.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/widgets/signin/signin_widget.dart';

class NavigationHelper {
  static void handleGoToPageOrLogin({
    required BuildContext context,
    required UserController userController,
    required void Function()
        navigateAction, // Function that performs the navigation
  }) {
    if (userController.user == null) {
      showModalBottomSheet<void>(
        context: context,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.3,
          child: Container(
            padding: const EdgeInsets.all(30),
            child: const SignInWidget(),
          ),
        ),
      );
    } else {
      // Perform the navigation action
      navigateAction();
    }
  }
}
