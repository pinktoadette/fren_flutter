// ignore_for_file: constant_identifier_names
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:machi_app/controller/main_binding.dart';
import 'package:machi_app/helpers/theme_helper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> commonInitialization() async {
  await Firebase.initializeApp();

  const activeEnv = String.fromEnvironment('flavor', defaultValue: 'prod');
  debugPrint("===== Running Env: $activeEnv ====");

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

  /// Revenue cat for subscription and payments
  await Purchases.setLogLevel(
      activeEnv.contains('prod') ? LogLevel.debug : LogLevel.info);

  if (Platform.isAndroid) {
    /// Google Play Revenue cat
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
  /// Check iOS device
  if (Platform.isIOS) {
    /// Apple Revenue cat setup
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
}
