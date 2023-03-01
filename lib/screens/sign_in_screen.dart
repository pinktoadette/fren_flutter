import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/screens/home_screen.dart';
import 'package:fren_app/screens/phone_number_screen.dart';
import 'package:fren_app/widgets/app_logo.dart';
import 'package:fren_app/widgets/default_button.dart';
import 'package:fren_app/widgets/terms_of_service_row.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fren_app/utils/google_auth.dart';
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

  bool google =false;

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Container(
        child: Container(
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
                  style: const TextStyle(fontSize: 18)),

              const Spacer(),

              /// Sign in with Social
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.maxFinite,
                  child: DefaultButton(
                    child: const Text("Login with Phone Number", style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      /// Go to google
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PhoneNumberScreen()));
                    },
                  ),
                ),
              ),

              const Divider(),

              /// Sign in
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SignInButton(
                      Buttons.Google,
                      onPressed:  () {
                        GoogleAuthentication()
                            .signInWithGoogle()
                            .then((UserCredential value){
                              user = value.user;
                              print(user);
                              if (user?.email != null) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const OnboardingScreen()));
                              }
                            });
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

              const Spacer(),

              // Terms of Service section
              TextButton(
                onPressed: () {
                  //slide up panel
                },
                child: Text(
                  _i18n.translate("by_tapping_log_in_you_agree_with_our"),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              TermsOfServiceRow(),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
