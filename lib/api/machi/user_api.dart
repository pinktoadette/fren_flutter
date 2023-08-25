import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/api_env.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/datas/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

/// Handles all user response and requests.
/// UserModel communicates with firebase, this communicates to api.machi
class UserApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = ApiConfiguration().getApiUrl();
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<User> getUser() async {
    String url = '${baseUri}user/user';
    debugPrint("Requesting URL $url");
    final response = await auth.retryGetRequest(url);
    final getData = response.data;
    return getData.toJson();
  }

  Future<User> getUserById(
      {required String userId, CancelToken? cancelToken}) async {
    String url = '${baseUri}user/get_userId?userId=$userId';
    debugPrint("Requesting URL $url");
    final response = await auth.retryGetRequest(url, cancelToken: cancelToken);
    final getData = response.data;

    User user = User.fromDocument(getData);
    return user;
  }

  Future<void> saveUser(Map<String, dynamic> data) async {
    try {
      String url = '${baseUri}user/user';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      await dio.post(url, data: data);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    try {
      String url = '${baseUri}user/user';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      await dio.put(url, data: data);
    } catch (error, s) {
      debugPrint(error.toString());
      await FirebaseCrashlytics.instance.recordError(error, s,
          reason: 'Update user failed in signing: ${error.toString()}',
          fatal: true);
    }
  }

  Future<bool> checkUsername(String username) async {
    try {
      String url = '${baseUri}user/username_available?username=$username';
      debugPrint("Requesting URL $url");
      final response = await auth.retryGetRequest(url);
      return response.data;
    } catch (error) {
      debugPrint(error.toString());
    }
    return false;
  }

  Future<void> deactivateAccount() async {
    try {
      String url = '${baseUri}user/deactivate';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      await dio.post(url);
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }
}
