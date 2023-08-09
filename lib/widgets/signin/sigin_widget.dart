import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/blocked_account_screen.dart';
import 'package:machi_app/screens/first_time/interest_screen.dart';
import 'package:machi_app/screens/first_time/onboarding.dart';
import 'package:machi_app/screens/home_screen.dart';
import 'package:machi_app/screens/first_time/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:machi_app/screens/sign_in_screen.dart';
import 'package:machi_app/widgets/button/loading_button.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({Key? key}) : super(key: key);

  @override
  _SignInWidgetState createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  late AppLocalizations _i18n;
  User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;
  bool google = false;

  /// Navigate to next page
  void _nextScreen(screen) {
    // Go to next page route
    Future(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => screen), (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return SignInButton(Buttons.Google,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ), onPressed: () {
      setState(() {
        isLoading = true;
      });
      if (isLoading) loadingButton(size: 20);
      UserModel().signInWithGoogle(checkUserAccount: () {
        /// Authenticate User Account
        UserModel().authUserAccount(
            signInScreen: () => _nextScreen(const SignInScreen()),
            signUpScreen: () => _nextScreen(const SignUpScreen()),
            walkthruScreen: () => _nextScreen(const OnboardingScreen()),
            interestScreen: () => _nextScreen(const InterestScreen()),
            homeScreen: () => _nextScreen(const HomeScreen()),
            blockedScreen: () => _nextScreen(const BlockedAccountScreen()));
      }, onError: () async {
        // Show error message to user
        Get.snackbar(
          _i18n.translate("Error"),
          _i18n.translate("an_error_has_occurred"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_ERROR,
        );
      }).whenComplete(() => setState(() {
            isLoading = false;
          }));
    });
  }
}
