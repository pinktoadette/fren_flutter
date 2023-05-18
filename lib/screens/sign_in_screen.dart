import 'dart:async';

import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/home_screen.dart';
import 'package:machi_app/screens/first_time/sign_up_screen.dart';
import 'package:machi_app/screens/first_time/update_location_sceen.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:machi_app/widgets/chat/typing_indicator.dart';
import 'package:machi_app/widgets/animations/loader.dart';
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
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: screenWidth * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: screenHeight * 0.15),
              Frankloader(),
              Image.asset("assets/images/machi.png"),
              Text(_i18n.translate("app_short_description"),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(
                height: 20,
              ),
              const Spacer(),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child:

                      /// Sign in
                      Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        if (isLoading == true)
                          SizedBox(
                            width: 50,
                            child: JumpingDots(
                              color: Colors.black,
                            ),
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
                                onboardScreen: () =>
                                    _nextScreen(const OnboardingScreen()),
                                homeScreen: () =>
                                    _nextScreen(const HomeScreen()),
                                blockedScreen: () =>
                                    _nextScreen(const BlockedAccountScreen()));
                          }, onError: () async {
                            setState(() {
                              isLoading = false;
                            });
                            // Show error message to user
                            errorDialog(context,
                                message:
                                    _i18n.translate("an_error_has_occurred"));
                          }).whenComplete(() => setState(() {
                                isLoading = false;
                              }));
                        }),
                        SignInButton(
                          Buttons.Apple,
                          onPressed: () {},
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
