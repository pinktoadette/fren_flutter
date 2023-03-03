import 'dart:io';

import 'package:country_code_picker/country_localizations.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/models/app_model.dart';
import 'package:fren_app/screens/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:google_fonts/google_fonts.dart';


// TODO: Please "scroll down" to see the instructions to fix it.
import 'firebase_options.dart';

void main() async {

  final result = await InternetAddress.lookup('google.com');
  if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    print('Has Internet');
  } else {
    print("no internet");
  }
  // Initialized before calling runApp to init firebase app
  WidgetsFlutterBinding.ensureInitialized();

  /// ***  Initialize Firebase App *** ///
  /// 👉 Please check the [Documentation - README FIRST] instructions in the
  /// Table of Contents at section: [NEW - Firebase initialization for Fren App]
  /// in order to fix it and generate the required [firebase_options.dart] for your app.
  /// TODO:
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("start");
  // Initialize Google Mobile Ads SDK
  // await MobileAds.instance.initialize();

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  /// Check iOS device
  if (Platform.isIOS) {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  runApp(const MyApp());
}

// Define the Navigator global key state to be used when the build context is not available!
final navigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final textTheme = Theme.of(context).textTheme;
    return ScopedModel<AppModel>(
      model: AppModel(),
      child: ScopedModel<UserModel>(
        model: UserModel(),
        child: MaterialApp(
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          title: APP_NAME,
          debugShowCheckedModeBanner: false,

          /// Setup translations
          localizationsDelegates: const [
            // AppLocalizations is where the lang translations is loaded
            AppLocalizations.delegate,
            CountryLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: SUPPORTED_LOCALES,

          /// Returns a locale which will be used by the app
          localeResolutionCallback: (locale, supportedLocales) {
            // Check if the current device locale is supported
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale!.languageCode) {
                return supportedLocale;
              }
            }

            /// If the locale of the device is not supported, use the first one
            /// from the list (English, in this case).
            return supportedLocales.first;
          },
          home: const SplashScreen(),
          theme: _appTheme(),
        ),
      ),
    );
  }

  // App theme
  ThemeData _appTheme() {

    return ThemeData(
      primaryColor: APP_PRIMARY_COLOR,
      colorScheme: const ColorScheme.light().copyWith(
          primary: APP_PRIMARY_COLOR,
          secondary: APP_ACCENT_COLOR,
          background: APP_PRIMARY_COLOR),
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
          errorStyle: const TextStyle(fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
          )),
      textTheme: TextTheme(
        headline1: GoogleFonts.roboto(
            color: APP_PRIMARY_COLOR,
            fontSize: 97, fontWeight: FontWeight.w300, letterSpacing: -1.5),
        headline2: GoogleFonts.roboto(
            fontSize: 61, fontWeight: FontWeight.w300, letterSpacing: -0.5),
        headline3: GoogleFonts.roboto(fontSize: 48, fontWeight: FontWeight.w400),
        headline4: GoogleFonts.roboto(
            fontSize: 34, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        headline5: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w400),
        headline6: GoogleFonts.roboto(
            fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        subtitle1: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15),
        subtitle2: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        bodyText1: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
        bodyText2: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        button: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
        caption: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
        overline: GoogleFonts.poppins(
            fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
      ),
      appBarTheme: const AppBarTheme(
        color: Colors.white,
        elevation: 0, //Platform.isIOS ? 0 : 4.0,
        iconTheme: IconThemeData(color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(color: Colors.grey, fontSize: 18),
      ),
    );
  }
}
