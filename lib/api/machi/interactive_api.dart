import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/api_env.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/api/machi/cache_manager_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:machi_app/datas/interactive.dart';
import 'package:machi_app/helpers/load_theme.dart';

/// Handles all interactive response and requests.
/// This is an interactive story feature. Not used.
class InteractiveBoardApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = ApiConfiguration().getApiUrl();
  final auth = AuthApi();
  CachingHelper cachingHelper = CachingHelper();

  List<InteractiveTheme> themes = [];

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  InteractiveBoardApi() {
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    try {
      themes = await loadThemes();
    } catch (e) {
      debugPrint("Error loading themes: $e");
    }
  }

  Future<InteractiveBoard> postInteractive(
      {required CreateNewInteractive prompt}) async {
    /// @todo isPrivate = false until have more post, then make it private
    String url = '${baseUri}interactive/post';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url, data: {
      "prompt": prompt.prompt,
      "hiddenPrompt": prompt.hiddenPrompt,
      "isPrivate": false,
      "sequence": 4,
      "themeId": prompt.theme.id
    });
    final getData = response.data;
    InteractiveTheme theme =
        themes.firstWhere((theme) => getData[INTERACTIVE_THEME_ID] == theme.id);

    InteractiveBoard interactive = InteractiveBoard.fromJson(getData, theme);
    return interactive;
  }

  Future<List<InteractiveBoard>> getAllInteractive({required int page}) async {
    String url = '${baseUri}interactive/all?page=$page';
    debugPrint("Requesting URL $url");
    final response = await auth.retryGetRequest(url);
    final data = response.data;

    List<InteractiveBoard> boards = [];

    for (var board in data) {
      InteractiveTheme theme = themes
          .firstWhere((t) => board[INTERACTIVE_THEME_ID] == t.id.toString());

      InteractiveBoard interactive = InteractiveBoard.fromJson(board, theme);
      boards.add(interactive);
    }
    return boards;
  }

  Future<InteractiveBoardPrompt> getInteractiveId(String interactiveId) async {
    final String url =
        '${baseUri}interactive/post?interactiveId=$interactiveId';
    debugPrint("Requesting URL $url");

    final api1CachedData =
        await cachingHelper.cachedUrl(url, const Duration(minutes: 2));
    if (api1CachedData != null) {
      return InteractiveBoardPrompt.fromJson(api1CachedData);
    }

    try {
      final response = await auth.retryGetRequest(url);
      final Map<String, dynamic> responseData = response.data;

      final prompts = InteractiveBoardPrompt.fromJson(responseData);

      await cachingHelper.cacheUrl(
          url, responseData, const Duration(seconds: 30));
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
