import 'dart:async';

import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/home_screen.dart';
import 'package:fren_app/screens/sign_up_screen.dart';
import 'package:fren_app/screens/update_location_sceen.dart';
import 'package:fren_app/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../dialogs/common_dialogs.dart';
import 'blocked_account_screen.dart';
import 'chat_bot.dart';
import 'on_boarding_screen.dart';

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
  bool google =false;

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
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: screenWidth * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),

              /// App logo
              const AppLogo(),

              /// App name
              Text(APP_NAME, style: Theme.of(context).textTheme.displayLarge),

              const SizedBox(height: 10),

              Text(_i18n.translate("app_short_description"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black )),

              const Spacer(),
              if (isLoading == true) const CircularProgressIndicator(),

              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child:
                  /// Sign in
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SignInButton(
                            Buttons.Google,
                            onPressed:  () {
                                isLoading = true;
                                UserModel().signInWithGoogle(
                                  checkUserAccount: () {
                                    /// Authenticate User Account
                                    UserModel().authUserAccount(
                                        updateLocationScreen: () => _nextScreen(const UpdateLocationScreen()),
                                        signInScreen: () => _nextScreen(const SignInScreen()),
                                        signUpScreen: () => _nextScreen(const SignUpScreen()),
                                        // botChatScreen: (bot) => _nextScreen(BotChatScreen(bot: bot)),
                                        onboardScreen: () => _nextScreen(const OnboardingScreen()),
                                        homeScreen: () => _nextScreen(const HomeScreen()),
                                        blockedScreen: () => _nextScreen(const BlockedAccountScreen())
                                    );
                                  },
                                    onError: () async {
                                      // Hide dialog
                                      // await _pr.hide();
                                      // Show error message to user
                                      errorDialog(context,
                                          message: _i18n.translate("an_error_has_occurred"));
                                    }).whenComplete(() => isLoading = false );
                            }
                        ),
                        SignInButton(
                          Buttons.Apple,
                          onPressed: () {
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              /// Sign in with Phone
              // Padding(
              //   padding: const EdgeInsets.all(20),
              //   child: SizedBox(
              //     child: DefaultButton(
              //       child: const Text("Login with Phone Number", style: TextStyle(fontSize: 18)),
              //       onPressed: () {
              //         /// Go to google
              //         Navigator.of(context).push(MaterialPageRoute(
              //             builder: (context) => const PhoneNumberScreen()));
              //       },
              //     ),
              //   ),
              // ),

              // // Terms of Service section
              // TextButton(
              //   onPressed: () {
              //     //slide up panel
              //   },
              //   child: Text(
              //     _i18n.translate("by_tapping_log_in_you_agree_with_our"),
              //     style: const TextStyle(
              //         color: Colors.white, fontWeight: FontWeight.bold),
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              //
              // TermsOfServiceRow(),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
