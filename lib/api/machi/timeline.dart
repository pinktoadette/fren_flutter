import 'package:flutter/cupertino.dart';
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class TimelineApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<List<dynamic>> getTimeline(int limit, int offset) async {
    String url = '${baseUri}timeline/feed?limit=$limit&offset=$offset';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.get(url);
    final data = response.data;
    return data;
  }
}
