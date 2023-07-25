import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:machi_app/datas/interactive.dart';

class InteractiveBoardApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find(tag: 'bot');
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<InteractiveBoard> postInteractive(
      {required String prompt, String? photoUrl, int? seq}) async {
    String url = '${baseUri}interactive/post';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url,
        data: {"prompt": prompt, "photoUrl": photoUrl, "sequence": seq ?? 3});
    final getData = response.data;

    InteractiveBoard interactive = InteractiveBoard.fromJson(getData);
    return interactive;
  }

  Future<List<InteractiveBoard>> getAllInteractive({required int page}) async {
    String url = '${baseUri}interactive/all?page=$page';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.get(url);
    final getData = response.data;

    List<InteractiveBoard> boards = [];
    for (var i; i < getData.length; i++) {
      InteractiveBoard interactive = InteractiveBoard.fromJson(getData[i]);
      boards.add(interactive);
    }
    return boards;
  }

  Future<InteractiveBoardPrompt> getInteractiveId(String interactiveId) async {
    String url = '${baseUri}interactive/pose?interactiveId=$interactiveId';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.get(url);
    final getData = response.data;

    InteractiveBoardPrompt prompts = InteractiveBoardPrompt.fromJson(getData);
    return prompts;
  }
}
