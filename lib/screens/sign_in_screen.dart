
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/screens/phone_number_screen.dart';
import 'package:fren_app/widgets/app_logo.dart';
import 'package:fren_app/widgets/default_button.dart';
import 'package:fren_app/widgets/terms_of_service_row.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/helpers/app_localizations.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Variables
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late AppLocalizations _i18n;

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Container(
        // Background image
        // decoration: const BoxDecoration(
        //   image: DecorationImage(
        //       image: AssetImage("assets/images/background_image.jpg"),
        //       fit: BoxFit.cover,
        //       repeat: ImageRepeat.noRepeat),
        // ),
        child: Container(
          // decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //         begin: Alignment.bottomRight,
          //         colors: [
          //           Theme.of(context).primaryColor,
          //           //.withOpacity(.4)
          //           Colors.white])),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

            Spacer(),

            /// App logo
            // const AppLogo(),

            /// App name
            Text(APP_NAME,
                style: Theme.of(context).textTheme.headline1),

            // const SizedBox(height: 5),
            // Text(_i18n.translate("welcome_back"),
            //   textAlign: TextAlign.center,
            //   style: const TextStyle(fontSize: 18, color: Colors.white)),

            const SizedBox(height: 10),

            Text(_i18n.translate("app_short_description"),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18)),

            Spacer(),

              /// Sign in with Social
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.maxFinite,
                  child: DefaultButton(
                    child: Text(
                        "Sign in with Google",
                        style: const TextStyle(fontSize: 18)),
                    onPressed: () {
                      /// Go to phone number screen
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PhoneNumberScreen()));
                    },
                  ),
                ),
              ),

              /// Sign in with Phone Number
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.maxFinite,
                  child: DefaultButton(
                    child: Text(
                        _i18n.translate("sign_in_with_phone_number"),
                        style: const TextStyle(fontSize: 18)),
                    onPressed: () {
                      /// Go to phone number screen
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PhoneNumberScreen()));
                    },
                  ),
                ),
              ),

              Spacer(),

              // Terms of Service section
              Text(
                _i18n.translate("by_tapping_log_in_you_agree_with_our"),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 7,
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
