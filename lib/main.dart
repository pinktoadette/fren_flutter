// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:machi_app/controller/main_binding.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/cache_manager.dart';
import 'package:machi_app/helpers/theme_helper.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/models/app_model.dart';
import 'package:machi_app/widgets/common/default_card_border.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/screens/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:leak_detector/leak_detector.dart';

void main() async {
  // Initialized before calling runApp to init firebase app
  WidgetsFlutterBinding.ensureInitialized();

  /// ***  Initialize Firebase App *** ///
  /// 👉 Please check the [Documentation - README FIRST] instructions in the
  /// Table of Contents at section: [NEW - Firebase initialization for Fren App]
  /// in order to fix it and generate the required [firebase_options.dart] for your app.
  await Firebase.initializeApp();
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = (errorDetails) async {
    if (errorDetails.library == "image resource service" &&
        errorDetails.exception
            .toString()
            .startsWith("HttpException: Invalid statusCode: 404, uri")) {
      return;
    }
    await FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  FirebaseMessaging.instance.requestPermission();

  /// Revenue CAt
  late PurchasesConfiguration configuration;

  if (Platform.isAndroid | Platform.isIOS) {
    /// Revenue cat for subscription and payments
    await Purchases.setLogLevel(LogLevel.info);

    /// Revenue cat
    configuration = PurchasesConfiguration('goog_EutdJZovasmfuBudvjOKZpEkGcx');

    /// firebase
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);
  } else if (Platform.isWindows | Platform.isMacOS) {
    /// firebase
    await FirebaseFirestore.instance
        .enablePersistence(const PersistenceSettings(synchronizeTabs: true));
  }
  // Initialize Google Mobile Ads SDK
  await MobileAds.instance.initialize();

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  /// Check iOS device
  if (Platform.isIOS) {
    /// Revenue cat setup
    configuration = PurchasesConfiguration('appl_StnVJbAaVHGAiEcqkJSBLnlhgFp');

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // revenue cat
  await Purchases.configure(configuration);

  // getx storyage
  await GetStorage.init();

  // GetX all Controller
  MainBinding mainBinding = MainBinding();
  await mainBinding.dependencies();

  // Load Theme
  await ThemeHelper().initialize();

  /// Schedule and Clear Cache
  await initializeCacheTimestampAndSchedule();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
// Define the Navigator global key state to be used when the build context is not available!
  final navigatorKey = GlobalKey<NavigatorState>();
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    LeakDetector().init(maxRetainingPath: 300);
    LeakDetector().onLeakedStream.listen((LeakedInfo info) {
      // Print to console
      debugPrint("=============== LeakedInfo Start *********************");
      debugPrint("gcRootType: ${info.gcRootType}");
      debugPrint("retainingPathJson: ${info.retainingPathJson}");

      debugPrint("Retaining Path:");
      for (var node in info.retainingPath) {
        debugPrint(node.toString());
      }
      debugPrint("=============== LeakedInfo End ***********************");

      // Show preview page
      showLeakedInfoPage(navigatorKey.currentContext!, info);
    });

    LeakDetector().onEventStream.listen((DetectorEvent event) {
      debugPrint("=============== Detector EVENT *********************");
      debugPrint(event.toString());
      if (event.type == DetectorEventType.startAnalyze) {
        debugPrint("=============== Detector Started *********************");
      } else if (event.type == DetectorEventType.endAnalyze) {
        debugPrint("=============== Detector Ended *********************");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppModel>(
      model: AppModel(),
      child: ScopedModel<UserModel>(
        model: UserModel(),
        child: GetMaterialApp(
          color: Colors.transparent,
          navigatorKey: navigatorKey,
          navigatorObservers: [
            //used the LeakNavigatorObserver
            LeakNavigatorObserver(
              shouldCheck: (route) {
                return route.settings.name != null &&
                    route.settings.name != '/';
              },
            ),
          ],
          scaffoldMessengerKey: scaffoldMessengerKey,
          title: APP_NAME,
          debugShowCheckedModeBanner: false,

          /// Setup translations
          localizationsDelegates: const [
            // AppLocalizations is where the lang translations is loaded
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
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
          themeMode: ThemeHelper().themeMode,
          theme: _lightTheme(),
          darkTheme: _darkTheme(),
        ),
      ),
    );
  }

  // App theme
  // ignore: unused_element
  ThemeData _lightTheme() {
    final ThemeData base = ThemeData.light();

    return base.copyWith(
      primaryColor: APP_PRIMARY_COLOR,
      colorScheme: const ColorScheme.light().copyWith(
        primary: APP_PRIMARY_COLOR,
        secondary: APP_ACCENT_COLOR,
        tertiary: APP_TERTIARY,
        tertiaryContainer: APP_TERTIARY, // drop shadow
        background: APP_PRIMARY_BACKGROUND,
      ),
      tabBarTheme: TabBarTheme(
        indicatorColor: APP_PRIMARY_COLOR,
        labelColor: APP_PRIMARY_COLOR,
        labelStyle: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black26),
        unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black54),
      ),
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: APP_PRIMARY_COLOR),
          floatingLabelStyle:
              GoogleFonts.poppins(fontSize: 16, color: APP_PRIMARY_COLOR),
          hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white30),
          errorStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: APP_ACCENT_COLOR, width: 2.0),
          )),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: APP_PRIMARY_COLOR,
      ),
      cardTheme: CardTheme(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          surfaceTintColor: Colors.transparent,
          elevation: 4.0,
          shape: defaultCardBorder()),
      textButtonTheme: TextButtonThemeData(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: APP_PRIMARY_BACKGROUND,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.black12,
        thickness: 1.0,
        space: 8.0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        modalBackgroundColor: Colors.white,
        backgroundColor: Colors.white70,
        clipBehavior: Clip.antiAlias,
        // set shape to make top corners rounded
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: APP_ACCENT_COLOR,
        selectionColor: Colors.green,
        selectionHandleColor: APP_ACCENT_COLOR,
      ),
      textTheme: TextTheme(
        displayLarge:
            GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w700),
        displayMedium:
            GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
        displaySmall: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w500, color: APP_ACCENT_COLOR),
        headlineLarge:
            GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700),
        headlineMedium:
            GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
        headlineSmall: GoogleFonts.poppins(
            color: APP_PRIMARY_COLOR,
            fontSize: 16,
            fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.poppins(fontSize: 18),
        titleSmall: GoogleFonts.poppins(fontSize: 16),
        bodyLarge:
            GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.normal),
        bodyMedium: GoogleFonts.poppins(fontSize: 16, color: APP_PRIMARY_COLOR),
        bodySmall: GoogleFonts.poppins(fontSize: 14),
        labelLarge:
            GoogleFonts.poppins(fontSize: 16, wordSpacing: 0, letterSpacing: 0),
        labelMedium: GoogleFonts.poppins(
            fontSize: 14,
            wordSpacing: 0,
            letterSpacing: 0,
            textStyle: const TextStyle(color: APP_ACCENT_COLOR)),
        labelSmall: GoogleFonts.poppins(
            fontSize: 12, wordSpacing: 0, letterSpacing: 0, color: Colors.grey),
      ).apply(
        bodyColor: APP_PRIMARY_COLOR,
        displayColor: APP_PRIMARY_COLOR,
      ),
      popupMenuTheme: PopupMenuThemeData(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      appBarTheme: const AppBarTheme(
        color: APP_PRIMARY_BACKGROUND,
        elevation: 0, //Platform.isIOS ? 0 : 4.0,
        iconTheme: IconThemeData(color: Colors.black),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white, // Only honored in Android M and above
            statusBarIconBrightness:
                Brightness.dark, // Only honored in Android M and above
            statusBarBrightness: Brightness.light),
        titleTextStyle: TextStyle(color: APP_PRIMARY_COLOR, fontSize: 18),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // dark
  ThemeData _darkTheme() {
    final ThemeData darkTheme = ThemeData.dark();
    const APP_PRIMARY_DARK_COLOR = Color.fromARGB(255, 184, 183, 183);
    const APP_PRIMARY_DARK_BACKGROUND = Color.fromARGB(255, 16, 16, 16);

    return darkTheme.copyWith(
      primaryColor: APP_PRIMARY_DARK_COLOR,
      colorScheme: const ColorScheme.dark().copyWith(
          primary: APP_PRIMARY_DARK_COLOR,
          secondary: APP_ACCENT_COLOR,
          tertiary: APP_TERTIARY,
          tertiaryContainer: Colors.black,
          background: APP_PRIMARY_DARK_BACKGROUND,
          inversePrimary: APP_PRIMARY_DARK_BACKGROUND,
          inverseSurface: APP_PRIMARY_DARK_COLOR),
      scaffoldBackgroundColor: APP_PRIMARY_DARK_BACKGROUND,
      dividerTheme: const DividerThemeData(
        color: Colors.white10,
        thickness: 1.0,
        space: 8.0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: APP_PRIMARY_DARK_BACKGROUND,
      ),
      tabBarTheme: TabBarTheme(
        indicatorColor: APP_PRIMARY_DARK_COLOR,
        labelColor: APP_PRIMARY_DARK_COLOR,
        labelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: APP_PRIMARY_DARK_COLOR),
        unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.normal, color: APP_TERTIARY),
      ),
      textSelectionTheme: const TextSelectionThemeData(
          cursorColor: APP_ACCENT_COLOR,
          selectionColor: Color.fromARGB(255, 26, 158, 107),
          selectionHandleColor: Color.fromARGB(255, 22, 136, 92)),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(17)),
        isDense: true,
        fillColor: APP_INPUT_COLOR,
        filled: true,
        labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: APP_PRIMARY_DARK_COLOR),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle:
            GoogleFonts.poppins(fontSize: 18, color: APP_PRIMARY_DARK_COLOR),
        hintStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: APP_INVERSE_PRIMARY_COLOR),
        errorStyle: const TextStyle(fontSize: 16),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: APP_PRIMARY_COLOR,
      ),
      dialogTheme: const DialogTheme(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentTextStyle: TextStyle(fontSize: 16, fontFamily: 'poppins'),
          backgroundColor: APP_PRIMARY_DARK_BACKGROUND),
      cardTheme: CardTheme(
          color: const Color.fromARGB(255, 26, 26, 26),
          shadowColor: Colors.black,
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          shape: defaultCardBorder()),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: APP_PRIMARY_DARK_COLOR,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: APP_PRIMARY_DARK_COLOR,
            foregroundColor: APP_PRIMARY_DARK_BACKGROUND,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: APP_PRIMARY_DARK_COLOR,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        modalBackgroundColor:
            APP_PRIMARY_DARK_BACKGROUND, //Color.fromRGBO(31, 31, 31, 1),
        backgroundColor: Color.fromARGB(255, 29, 29, 29),
        clipBehavior: Clip.antiAlias,
        // set shape to make top corners rounded
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: APP_PRIMARY_DARK_COLOR,
      ),
      textTheme: TextTheme(
        displayLarge:
            GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w700),
        displayMedium:
            GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
        displaySmall: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w500, color: APP_ACCENT_COLOR),
        headlineLarge:
            GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700),
        headlineMedium:
            GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
        headlineSmall: GoogleFonts.poppins(
            color: APP_PRIMARY_DARK_COLOR,
            fontSize: 16,
            fontWeight: FontWeight.bold),
        titleLarge:
            GoogleFonts.poppins(fontSize: 24, color: APP_PRIMARY_DARK_COLOR),
        titleMedium:
            GoogleFonts.poppins(fontSize: 18, color: APP_PRIMARY_DARK_COLOR),
        titleSmall:
            GoogleFonts.poppins(fontSize: 16, color: APP_PRIMARY_DARK_COLOR),
        bodyLarge:
            GoogleFonts.poppins(fontSize: 18, color: APP_PRIMARY_DARK_COLOR),
        bodyMedium:
            GoogleFonts.poppins(fontSize: 16, color: APP_PRIMARY_DARK_COLOR),
        bodySmall:
            GoogleFonts.poppins(fontSize: 14, color: APP_PRIMARY_DARK_COLOR),
        labelLarge: GoogleFonts.poppins(
            fontSize: 16,
            color: APP_PRIMARY_DARK_COLOR,
            wordSpacing: 0,
            letterSpacing: 0),
        labelMedium: GoogleFonts.poppins(
            fontSize: 14,
            wordSpacing: 0,
            letterSpacing: 0,
            textStyle: const TextStyle(color: APP_ACCENT_COLOR)),
        labelSmall:
            GoogleFonts.poppins(fontSize: 12, wordSpacing: 0, letterSpacing: 0),
      ),
      popupMenuTheme: PopupMenuThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      appBarTheme: const AppBarTheme(
        color: APP_PRIMARY_DARK_BACKGROUND,
        elevation: 0, //Platform.isIOS ? 0 : 4.0,
        iconTheme: IconThemeData(color: APP_PRIMARY_DARK_COLOR),
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor:
                APP_PRIMARY_DARK_BACKGROUND, // Only honored in Android M and above
            statusBarIconBrightness:
                Brightness.light, // Only honored in Android M and above
            statusBarBrightness: Brightness.dark),
        titleTextStyle:
            TextStyle(fontFamily: 'poppins', color: Colors.white, fontSize: 16),
      ),
    );
  }
}
