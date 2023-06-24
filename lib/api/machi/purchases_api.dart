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
    } on PlatformException {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> purchaseCredits() async {
    String url = '${baseUri}purchases/credits';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url);
    return response.data;
  }

  Future<Map<String, dynamic>> getCredits() async {
    String url = '${baseUri}subscriber/credits';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.get(url);
    return response.data;
  }
}
