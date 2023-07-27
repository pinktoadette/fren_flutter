import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/api/machi/cache_manager_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:machi_app/datas/interactive.dart';

class InteractiveBoardApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final _cachedApi = CachedApi();
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<InteractiveBoard> postInteractive(
      {required String prompt, String? photoUrl, int? seq}) async {
    /// @todo isPrivate = false until have more post, then make it private
    String url = '${baseUri}interactive/post';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url, data: {
      "prompt": prompt,
      "photoUrl": photoUrl,
      "sequence": seq ?? 3,
      "hidePrompt": false,
      "isPrivate": false
    });
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
    for (var board in getData) {
      InteractiveBoard interactive = InteractiveBoard.fromJson(board);
      boards.add(interactive);
    }
    return boards;
  }

  Future<InteractiveBoardPrompt> getInteractiveId(String interactiveId) async {
    final String url =
        '${baseUri}interactive/post?interactiveId=$interactiveId';
    debugPrint("Requesting URL $url");

    // final Map<String, dynamic>? cached = await _cachedApi.cachedUrl(url);
    // if (cached != null) {
    //   return InteractiveBoardPrompt.fromJson(cached);
    // }

    try {
      final dio = await auth.getDio();
      final response = await dio.get(url);
      final Map<String, dynamic> responseData = response.data;

      final prompts = InteractiveBoardPrompt.fromJson(responseData);

      // await _cachedApi.cacheUrl(url, responseData);
      return prompts;
    } catch (e) {
      debugPrint('Error fetching interactive ID: $e');
      rethrow;
    }
  }

  Future<InteractiveBoardPrompt> getNextPath(
      {required Map<String, dynamic> userResponse}) async {
    String url = '${baseUri}interactive/response';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url, data: userResponse);
    final getData = response.data;

    InteractiveBoardPrompt prompts = InteractiveBoardPrompt.fromJson(getData);
    return prompts;
  }

  Future<InteractiveBoardPrompt> getAnImage(
      {required Map<String, dynamic> userResponse}) async {
    String url = '${baseUri}interactive/image';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url, data: userResponse);
    final getData = response.data;

    InteractiveBoardPrompt prompts = InteractiveBoardPrompt.fromJson(getData);
    return prompts;
  }
}
