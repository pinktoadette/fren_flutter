import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/widgets/signin/sigin_widget.dart';

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
        isScrollControlled: true,
        enableDrag: true,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.2,
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Text(
                  "Sign In",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SignInWidget(),
              ],
            ),
          ),
        ),
      );
    } else {
      // Perform the navigation action
      navigateAction();
    }
  }
}
