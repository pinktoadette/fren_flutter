import 'dart:async';

import 'package:flutter/services.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:machi_app/widgets/signin/sigin_widget.dart';

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
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 50, bottom: 50),
                child: Image.asset("assets/images/logo_machi.png"),
                width: screenWidth * 0.5,
              ),
              Semantics(
                label: _i18n.translate("app_short_description"),
                child: Text(_i18n.translate("app_short_description"),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium),
              ),
              const Spacer(),
              const Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[SignInWidget()],
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
