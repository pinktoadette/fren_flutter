import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/gallery.dart';
import 'package:machi_app/datas/storyboard.dart';

class TimelineApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  ////
  /// TIMELINE is now STORYBOARD class, to make things less complicated / less features
  Future<List<Storyboard>> getTimeline(
      int limit, int page, bool? refresh) async {
    // String? refreshKey = refresh == true ? "&refresh=true" : "";
    String url = '${baseUri}timeline/user_feed?limit=$limit&page=$page';
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
    final dio = await auth.getDio();
    final response = await dio.get(url);
    List<Bot> bots = [];
    List<Gallery> galleries = [];
    List<Storyboard> storyboards = [];
    for (var machi in response.data['machi']) {
      Bot bot = Bot.fromDocument(machi);
      bots.add(bot);
    }

    for (var gall in response.data['gallery']) {
      Gallery gallery = Gallery.fromJson(gall);
      galleries.add(gallery);
    }

    for (var boards in response.data['story']) {
      Storyboard board = Storyboard.fromJson(boards);
      storyboards.add(board);
    }

    return {
      'machi': bots.toList(),
      'gallery': galleries.toList(),
      'story': storyboards.toList()
    };
  }
}
