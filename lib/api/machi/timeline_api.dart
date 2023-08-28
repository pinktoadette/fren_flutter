import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/api_env.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/api/machi/cache_manager_api.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/storyboard.dart';

/// Handles all timeline response and requests.
class TimelineApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = ApiConfiguration().getApiUrl();
  final auth = AuthApi();
  CachingHelper cachingHelper = CachingHelper();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  ////
  /// TIMELINE is now STORYBOARD class, to make things less complicated / less features
  Future<List<Storyboard>> getTimeline(
      int limit, int page, bool? refresh) async {
    UserController userController = Get.find(tag: 'user');

    String? refreshKey = refresh == true ? "&refresh=true" : "";
    String url =
        '${baseUri}timeline/user_feed?limit=$limit&page=$page$refreshKey';

    if (userController.user == null) {
      url = '${baseUri}timeline/public?limit=$limit&page=$page';
    }

    final response = await auth.retryGetRequest(url);
    final result = response.data;

    List<Storyboard> timeline = [];
    for (var data in result) {
      Storyboard time = Storyboard.fromJson(data);
      timeline.add(time);
    }
    return timeline;
  }

  Future<List<Storyboard>> getTimelineByPageUserId(String userId) async {
    String url = '${baseUri}timeline/user_timeline?userId=$userId';
    debugPrint("Requesting URL $url");
    final response = await auth.retryGetRequest(url);
    final result = response.data;

    List<Storyboard> timeline = [];
    for (var data in result) {
      Storyboard time = Storyboard.fromJson(data);
      timeline.add(time);
    }
    return timeline;
  }

  Future<String> likeStoryMachi(
      String itemType, String itemId, int actionValue) async {
    String url = '${baseUri}storyboard/like';
    debugPrint("Requesting URL $url");
    try {
      final dio = await auth.getDio();
      final response = await dio.post(url,
          data: {'itemType': itemType, 'itemId': itemId, 'value': actionValue});
      return response.data;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance
          .recordError(err, stack, reason: 'Failed  like story ', fatal: false);
      rethrow;
    }
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

    final response = await auth.retryGetRequest(url);
    if (response.statusCode == 200) {
      await cachingHelper.cacheUrl(
          url, response.data, const Duration(minutes: 5));
      Map<String, dynamic> result = _homeDatafromJson(response.data);
      return result;
    }
    return {};
  }

  Map<String, dynamic> _homeDatafromJson(Map<String, dynamic> data) {
    List<Bot> bots = [];
    List<Bot> mybots = [];

    for (var machi in data['machi']) {
      Bot bot = Bot.fromDocument(machi);
      bots.add(bot);
    }

    if (data['mymachi'] != null && data['mymachi'] is List) {
      for (var machi in data['mymachi']) {
        Bot bot = Bot.fromDocument(machi);
        mybots.add(bot);
      }
    }

    return {
      'machi': bots.toList(),
      'mymachi': mybots.toList(),
    };
  }

  Future<Map<String, dynamic>> getPublicHomepage() async {
    String url = '${baseUri}timeline/public_homepage';
    debugPrint("Requesting URL $url");

    final response = await auth.retryGetRequest(url);
    final data = response.data;

    List<Bot> bots = [];
    for (var machi in data['machi']) {
      Bot bot = Bot.fromDocument(machi);
      bots.add(bot);
    }

    return {
      'machi': bots.toList(),
    };
  }
}
