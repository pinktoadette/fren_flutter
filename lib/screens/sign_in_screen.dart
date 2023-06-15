import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/first_time/first_time_user.dart';
import 'package:machi_app/screens/home_screen.dart';
import 'package:machi_app/screens/first_time/sign_up_screen.dart';
import 'package:machi_app/screens/first_time/update_location_sceen.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/chat/typing_indicator.dart';
import '../dialogs/common_dialogs.dart';
import 'blocked_account_screen.dart';
import 'first_time/on_boarding_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Variables
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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
    /// Initialization
    _i18n = AppLocalizations.of(context);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: APP_PRIMARY_COLOR),
      ),
      key: _scaffoldKey,
      body: Container(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: screenWidth * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 100),
              Image.asset("assets/images/logo_machi.png"),
              const SizedBox(height: 40),
              Text(_i18n.translate("app_short_description"),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall),
              const Spacer(),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        if (isLoading == true)
                          Lottie.asset(
                            'assets/lottie/loader.json',
                          ),
                        SignInButton(Buttons.Google,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ), onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          UserModel().signInWithGoogle(checkUserAccount: () {
                            /// Authenticate User Account
                            UserModel().authUserAccount(
                                updateLocationScreen: () =>
                                    _nextScreen(const UpdateLocationScreen()),
                                signInScreen: () =>
                                    _nextScreen(const SignInScreen()),
                                signUpScreen: () =>
                                    _nextScreen(const SignUpScreen()),
                                interestScreen: () =>
                                    _nextScreen(const InterestScreen()),
                                onboardScreen: () =>
                                    _nextScreen(const OnboardingScreen()),
                                homeScreen: () =>
                                    _nextScreen(const HomeScreen()),
                                blockedScreen: () =>
                                    _nextScreen(const BlockedAccountScreen()));
                          }, onError: () async {
                            // Show error message to user
                            errorDialog(context,
                                message:
                                    _i18n.translate("an_error_has_occurred"));
                          }).whenComplete(() => setState(() {
                                isLoading = false;
                              }));
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
