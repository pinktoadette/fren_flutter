import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/api/machi/cache_manager_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:machi_app/constants/secrets.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/gallery.dart';
import 'package:machi_app/datas/storyboard.dart';

class TimelineApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();
  CachingHelper cachingHelper = CachingHelper();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  ////
  /// TIMELINE is now STORYBOARD class, to make things less complicated / less features
  Future<List<Storyboard>> getTimeline(
      int limit, int page, bool? refresh) async {
    UserController userController = Get.find(tag: 'user');

    // String? refreshKey = refresh == true ? "&refresh=true" : "";
    String url = '${baseUri}timeline/user_feed?limit=$limit&page=$page';

    if (userController.user == null) {
      url = '${baseUri}timeline/public?limit=$limit&page=$page';
    }

    final dio = userController.user == null
        ? await auth.getPublicDio()
        : await auth.getDio();
    final response = await dio.get(url);

    List<Storyboard> timeline = [];
    for (var data in response.data) {
      Storyboard time = Storyboard.fromJson(data);
      timeline.add(time);
    }
    return timeline;
  }

  Future<List<Storyboard>> getTimelineByPageUserId(String userId) async {
    String url = '${baseUri}timeline/user_timeline?userId=$userId';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.get(url);

    List<Storyboard> timeline = [];
    for (var data in response.data) {
      Storyboard time = Storyboard.fromJson(data);
      timeline.add(time);
    }
    return timeline;
  }

  Future<String> likeStoryMachi(
      String itemType, String itemId, int actionValue) async {
    String url = '${baseUri}storyboard/like';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url,
        data: {'itemType': itemType, 'itemId': itemId, 'value': actionValue});
    return response.data;
  }

  Future<Map<String, dynamic>> getHomepage() async {
    String url = '${baseUri}timeline/homepage';
    debugPrint("Requesting URL $url");

    final cachedData =
        await cachingHelper.cachedUrl(url, const Duration(minutes: 2));
    if (cachedData != null) {
      Map<String, dynamic> result = _homeDatafromJson(cachedData);
      return result;
    }

    final dio = await auth.getDio();
    final response = await dio.get(url);

    await cachingHelper.cacheUrl(
        url, response.data, const Duration(minutes: 5));
    Map<String, dynamic> result = _homeDatafromJson(response.data);
    return result;
  }

  Map<String, dynamic> _homeDatafromJson(Map<String, dynamic> data) {
    List<Bot> bots = [];
    List<Bot> mybots = [];
    List<Gallery> galleries = [];
    for (var machi in data['machi']) {
      Bot bot = Bot.fromDocument(machi);
      bots.add(bot);
    }

    for (var machi in data['mymachi']) {
      Bot bot = Bot.fromDocument(machi);
      mybots.add(bot);
    }

    for (var gall in data['gallery']) {
      Gallery gallery = Gallery.fromJson(gall);
      galleries.add(gallery);
    }

    return {
      'machi': bots.toList(),
      'mymachi': mybots.toList(),
      'gallery': galleries.toList(),
    };
  }

  Future<Map<String, dynamic>> getPublicHomepage() async {
    String url = '${baseUri}timeline/public_homepage';
    debugPrint("Requesting URL $url");

    final dio = await auth.getPublicDio();
    final response = await dio.get(url);
    final data = response.data;

    List<Bot> bots = [];
    List<Gallery> galleries = [];
    for (var machi in data['machi']) {
      Bot bot = Bot.fromDocument(machi);
      bots.add(bot);
    }

    for (var gall in data['gallery']) {
      Gallery gallery = Gallery.fromJson(gall);
      galleries.add(gallery);
    }

    return {
      'machi': bots.toList(),
      'gallery': galleries.toList(),
    };
  }
}
