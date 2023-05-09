import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:machi_app/helpers/date_format.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchasesApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();
  static const API_KEY = '';

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  static Future init() async {
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration(API_KEY);
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      return current == null ? [] : [current];
    } on PlatformException catch (e) {
      return [];
    }
  }
}
