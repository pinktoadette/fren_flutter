import 'dart:async';
import 'dart:io';

import 'package:machi_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:machi_app/plugins/geoflutterfire/geoflutterfire.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/models/app_model.dart';

class AppHelper {
  /// Local variables
  final _firestore = FirebaseFirestore.instance;

  // Update User location data in database
  Future<void> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required String country,
    required String locality,
  }) async {
    /// Initialize geoflutterfire instance
    final geo = Geoflutterfire();

    /// Set Geolocation point
    final GeoFirePoint geoPoint =
        geo.point(latitude: latitude, longitude: longitude);

    // Update user location data in database
    await UserModel().updateUserData(userId: userId, data: {
      USER_GEO_POINT: geoPoint.data,
      USER_COUNTRY: country,
      USER_LOCALITY: locality
    });
  }

  /// Get app store URL - Google Play / Apple Store
  String get _appStoreUrl {
    // Variables
    String url = "";
    final String androidPackageName = AppModel().appInfo.androidPackageName;
    final String iOsAppId = AppModel().appInfo.iOsAppId;

    // Check device OS
    if (Platform.isAndroid) {
      url = "https://play.google.com/store/apps/details?id=$androidPackageName";
    } else if (Platform.isIOS) {
      url = "https://apps.apple.com/app/id$iOsAppId";
    }
    return url;
  }

  Future<String> getRevenueCat() async {
    final DocumentSnapshot<Map<String, dynamic>> appInfo =
        await _firestore.collection(C_APP_INFO).doc('settings').get();

    // Update AppInfo object
    AppModel().setAppInfo(appInfo.data() ?? {});
    // Check Platform
    if (Platform.isAndroid) {
      return appInfo.data()?[REVENUE_CAT_ANDROID_IDENTIFIER] ?? "Imagine";
    } else if (Platform.isIOS) {
      return appInfo.data()?[REVENUE_CAT_ANDROID_IDENTIFIER] ?? "Imagine";
    }
    return "Imagine";
  }

  /// Get app current version from Cloud Firestore Database,
  /// that is the same with Google Play Store / Apple Store app version
  Future<int> getAppStoreVersion() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> appInfo =
          await _firestore.collection(C_APP_INFO).doc('settings').get();
      // Update AppInfo object
      AppModel().setAppInfo(appInfo.data() ?? {});
      // Check Platform
      if (Platform.isAndroid) {
        return appInfo.data()?[ANDROID_APP_CURRENT_VERSION] ?? 1;
      } else if (Platform.isIOS) {
        return appInfo.data()?[IOS_APP_CURRENT_VERSION] ?? 1;
      }
      return 1;
    } catch (err) {
      debugPrint(err.toString());
      return 0;
    }
  }

  /// Update app info data in database
  Future<void> updateAppInfo(Map<String, dynamic> data) async {
    // Update app data
    _firestore.collection(C_APP_INFO).doc('settings').update(data);
  }

  /// Share app method
  Future<void> shareApp() async {
    Share.share(_appStoreUrl);
  }

  /// Review app method
  Future<void> reviewApp() async {
    // Check OS and get correct url
    final String storeLink =
        Platform.isIOS ? "$_appStoreUrl?action=write-review" : _appStoreUrl;

    final Uri url = Uri.parse(storeLink);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch url: $url";
    }
  }

  /// Open app store - Google Play / Apple Store
  Future<void> openAppStore() async {
    // Get URL
    final Uri url = Uri.parse(_appStoreUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch url: $_appStoreUrl";
    }
  }

  /// Open Privacy Policy Page in Browser
  Future<void> openPrivacyPage() async {
    // Get URL
    final Uri url = Uri.parse(AppModel().appInfo.privacyPolicyUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch url: ${AppModel().appInfo.privacyPolicyUrl}";
    }
  }

  /// Open Terms of Services in Browser
  Future<void> openTermsPage() async {
    // Get URL
    final Uri url = Uri.parse(AppModel().appInfo.termsOfServicesUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch url: ${AppModel().appInfo.termsOfServicesUrl}";
    }
  }

  /// This allows a value of type T or T?
  /// to be treated as a value of type T?.
  T? ambiguate<T>(T? value) => value;
}
