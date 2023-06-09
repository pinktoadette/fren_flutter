import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:machi_app/datas/gallery.dart';

class GalleryApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<List<Gallery>> getUserGallery(
      {required String userId, int? page}) async {
    try {
      String url = '${baseUri}gallery/gallery?userId=$userId&page=$page';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.get(url);
      List<Gallery> galleries = [];
      for (Map<String, dynamic> gallery in response.data) {
        Gallery gal = Gallery.fromJson(gallery);
        galleries.add(gal);
      }

      return galleries;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<String> addUserGallery({required String messageId}) async {
    try {
      String url = '${baseUri}gallery/gallery';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {CHAT_MESSAGE_ID: messageId});
      return response.data;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }
}
