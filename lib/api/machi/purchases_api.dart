import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchasesApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  static Future init() async {
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration('goog_EutdJZovasmfuBudvjOKZpEkGcx');
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      init();
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      return current == null ? [] : [current];
    } on PlatformException catch (error) {
      return Future.error(error.toString());
    }
  }

  Future<Map<String, dynamic>> purchaseCredits(int maxRetries) async {
    const initialDelay = Duration(seconds: 1);
    ErrorAndStack? errorStackList;

    for (int retry = 0; retry < maxRetries; retry++) {
      try {
        String url = '${baseUri}purchases/credits';
        debugPrint("Requesting URL $url");
        final dio = await auth.getDio();
        final response = await dio.post(url);
        return response.data;
      } catch (err, stack) {
        debugPrint("Attempt $retry failed: ${err.toString()}");
        await Future.delayed(initialDelay * (1 << retry));
        if ((maxRetries - 1) == retry) {
          errorStackList = ErrorAndStack(err, stack);
        }
      }
    }

    if (errorStackList != null) {
      await FirebaseCrashlytics.instance.recordError(
          errorStackList.error, errorStackList.stack,
          reason:
              'Purchase credits failed (Attempt ${maxRetries.toString()}): ${errorStackList.error.toString()}',
          fatal: false);
    }
    // If all retries fail, rethrow the last error.
    throw Exception("Failed after $maxRetries retries");
  }

  Future<Map<String, dynamic>> getCredits() async {
    String url = '${baseUri}subscriber/credits';
    debugPrint("Requesting URL $url");
    final response = await auth.retryGetRequest(url);
    Map<String, dynamic> credits = response.data;
    return credits;
  }

  Future<Map<String, dynamic>> getRewards() async {
    String url = '${baseUri}rewards/credits';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url);
    return response.data;
  }
}
