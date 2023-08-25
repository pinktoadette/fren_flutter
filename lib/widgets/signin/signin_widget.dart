import 'dart:async';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/main_binding.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/blocked_account_screen.dart';
import 'package:machi_app/screens/first_time/interest_screen.dart';
import 'package:machi_app/screens/first_time/onboarding.dart';
import 'package:machi_app/screens/first_time/profile_image_upload.dart';
import 'package:machi_app/screens/home_screen.dart';
import 'package:machi_app/screens/first_time/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:machi_app/screens/sign_in_screen.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({Key? key}) : super(key: key);

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  TimelineController timelineController = Get.find(tag: 'timeline');
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        _i18n.translate("sign_in"),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      if (isLoading == true)
        Lottie.asset('assets/lottie/loader.json', height: 60)
      else
        const SizedBox(height: 60),
      SignInButton(Buttons.Google,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ), onPressed: () async {
        setState(() {
          isLoading = true;
        });

        /// clear timeline from public view
        Get.deleteAll();

        /// Need to reassign
        MainBinding mainBinding = MainBinding();
        await mainBinding.dependencies();

        UserModel().signInWithGoogle(checkUserAccount: () {
          /// Authenticate User Account
          UserModel().authUserAccount(
              signInScreen: () => _nextScreen(const SignInScreen()),
              signUpScreen: () => _nextScreen(const SignUpScreen()),
              profileImageScreen: () =>
                  _nextScreen(const ProfileImageGenerator()),
              walkthruScreen: () => _nextScreen(const OnboardingScreen()),
              interestScreen: () => _nextScreen(const InterestScreen()),
              homeScreen: () => _nextScreen(const HomeScreen()),
              blockedScreen: () => _nextScreen(const BlockedAccountScreen()));
        }, onError: (error) async {
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
      })
    ]);
  }
}
