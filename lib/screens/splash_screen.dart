import 'dart:io';

import 'package:flutter/services.dart';
import 'package:machi_app/screens/blocked_account_screen.dart';
import 'package:machi_app/screens/first_time/interest_screen.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_helper.dart';
import 'package:machi_app/screens/first_time/onboarding.dart';
import 'package:machi_app/screens/first_time/profile_image_upload.dart';
import 'package:machi_app/screens/update_app_screen.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/home_screen.dart';
import 'package:machi_app/screens/first_time/sign_up_screen.dart';
import 'package:machi_app/tabs/activity_tab.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Variables
  final AppHelper _appHelper = AppHelper();

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
            signInScreen: () => _nextScreen(const ActivityTab()),
            signUpScreen: () => _nextScreen(const SignUpScreen()),
            walkthruScreen: () => _nextScreen(const OnboardingScreen()),
            profileImageScreen: () =>
                _nextScreen(const ProfileImageGenerator()),
            interestScreen: () => _nextScreen(const InterestScreen()),
            homeScreen: () => _nextScreen(const HomeScreen()),
            blockedScreen: () => _nextScreen(const BlockedAccountScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: APP_TERTIARY),
      ),
      body: Center(
        child: SizedBox(
          width: 200,
          child: Image.asset("assets/images/astronaut.png"),
        ),
      ),
    );
  }
}
