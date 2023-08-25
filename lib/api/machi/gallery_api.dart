import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/api_env.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:machi_app/datas/gallery.dart';

/// Handles all images in user's gallery response and requests.
class GalleryApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = ApiConfiguration().getApiUrl();
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<List<Gallery>> getUserGallery(
      {required String userId, int? page, CancelToken? cancelToken}) async {
    try {
      String url = '${baseUri}gallery/gallery?userId=$userId&page=$page';
      debugPrint("Requesting URL $url");
      final response =
          await auth.retryGetRequest(url, cancelToken: cancelToken);
      final data = response.data;
      List<Gallery> galleries = [];
      for (Map<String, dynamic> gallery in data) {
        Gallery gal = Gallery.fromJson(gallery);
        galleries.add(gal);
      }

      return galleries;
    } catch (error) {
      return Future.error(error.toString());
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
      return Future.error(error.toString());
    }
  }

  Future<List<Gallery>> allGallery(
      {required int page, bool? refresh, CancelToken? cancelToken}) async {
    try {
      String? refreshKey = refresh == true ? "&refresh=true" : "";

      String url =
          '${baseUri}gallery/all_gallery?page=$page$refreshKey&limit=21';
      debugPrint("Requesting URL $url");
      final response =
          await auth.retryGetRequest(url, cancelToken: cancelToken);
      final data = response.data;
      List<Gallery> galleries = [];
      for (Map<String, dynamic> gallery in data) {
        Gallery gal = Gallery.fromJson(gallery);
        galleries.add(gal);
      }

      return galleries;
    } catch (error) {
      return Future.error(error.toString());
    }
  }
}
