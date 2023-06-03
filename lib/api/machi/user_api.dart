import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class UserApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<User> getUser() async {
    String url = '${baseUri}user/user';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.get(url);
    final getData = response.data;
    return getData.toJson();
  }

  Future<User> getUserById(String userId) async {
    String url = '${baseUri}user/get_userId?userId=$userId';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.get(url);
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
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<bool> checkUsername(String username) async {
    try {
      String url = '${baseUri}user/username_available?username=$username';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.get(url);
      return response.data;
    } catch (error) {
      debugPrint(error.toString());
    }
    return false;
  }
}
