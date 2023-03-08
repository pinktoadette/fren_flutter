import 'dart:io';

import 'package:fren_app/controller/user_controller.dart';
import 'package:fren_app/screens/blocked_account_screen.dart';
import 'package:fren_app/screens/first_time/update_location_sceen.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/helpers/app_helper.dart';
import 'package:fren_app/screens/update_app_screen.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/home_screen.dart';
import 'package:fren_app/screens/first_time/sign_up_screen.dart';
import 'package:fren_app/screens/sign_in_screen.dart';
import 'package:get/get.dart';

import 'chat_bot.dart';
import 'first_time/on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final BotController botController = Get.put(BotController());
  final UserController userController = Get.put(UserController());

  // Variables
  final AppHelper _appHelper = AppHelper();
  late AppLocalizations _i18n;

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
    _appHelper.getAppStoreVersion().then((storeVersion) async {
      debugPrint('storeVersion: $storeVersion');

      // Get hard coded App current version
      int appCurrentVersion = 1;
      // Check Platform
      if (Platform.isAndroid) {
        // Get Android version number
        appCurrentVersion = ANDROID_APP_VERSION_NUMBER;
      } else if (Platform.isIOS) {
        // Get iOS version number
        appCurrentVersion = IOS_APP_VERSION_NUMBER;
      }

      /// Compare both versions
      if (storeVersion > appCurrentVersion) {
        /// Go to update app screen
        _nextScreen(const UpdateAppScreen());
        debugPrint("Go to update screen");
      } else {
        /// Authenticate User Account
        UserModel().authUserAccount(
            updateLocationScreen: () => _nextScreen(const UpdateLocationScreen()),
            signInScreen: () => _nextScreen(const SignInScreen()),
            signUpScreen: () => _nextScreen(const SignUpScreen()),
            onboardScreen: () => _nextScreen(const OnboardingScreen()),
            homeScreen: () => _nextScreen(const HomeScreen()),
            blockedScreen: () => _nextScreen(const BlockedAccountScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Frankloader()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
