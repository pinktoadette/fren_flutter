import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/datas/timeline.dart';
import 'package:get/get.dart';

class TimelineApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<List<Storyboard>> getTimeline() async {
    final TimelineController timelineController = Get.find(tag: 'timeline');
    int limit = timelineController.limit;
    int offset = timelineController.offset;

    String url = '${baseUri}timeline/user_feed?limit=$limit&offset=$offset';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.get(url);

    List<Storyboard> timeline = [];
    for (var data in response.data) {
      Storyboard time = Storyboard.fromJson(data);
      timelineController.fetchMyTimeline(time);
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
}
