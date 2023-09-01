import 'package:flutter/material.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/first_time/onboarding.dart';
import 'package:machi_app/screens/first_time/profile_image_upload.dart';
import 'package:machi_app/screens/blocked_account_screen.dart';
import 'package:machi_app/screens/first_time/interest_screen.dart';
import 'package:machi_app/screens/home_screen.dart';
import 'package:machi_app/screens/first_time/sign_up_screen.dart';
import 'package:machi_app/tabs/activity_tab.dart';
import 'package:machi_app/widgets/animations/loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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

    /// Authenticate User Account
    UserModel().authUserAccount(
        signInScreen: () => _nextScreen(const ActivityTab()),
        signUpScreen: () => _nextScreen(const SignUpScreen()),
        walkthruScreen: () => _nextScreen(const OnboardingScreen()),
        profileImageScreen: () => _nextScreen(const ProfileImageGenerator()),
        interestScreen: () => _nextScreen(const InterestScreen()),
        homeScreen: () => _nextScreen(const HomeScreen()),
        blockedScreen: () => _nextScreen(const BlockedAccountScreen()));
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: height,
        child: const Frankloader(
          width: 400,
        ),
      ),
    );
  }
}
