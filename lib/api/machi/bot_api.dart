import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:uuid/uuid.dart';

class BotApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = "${PY_API}bot/";
  final BotController botControl = Get.find(tag: 'bot');
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<Bot> createBot(
      {required String name,
      required String prompt,
      String? botId,
      int? temperature,
      bool? isPrivate,
      String? photoUrl,
      required BotModelType modelType}) async {
    String url = '${baseUri}machi';
    String uuid = const Uuid().v4().replaceAll("[\\s\\-()]", "");

    Map<String, dynamic> payload = {
      BOT_ID: botId ?? "Machi_${uuid.substring(0, 10)}", // external botId
      BOT_NAME: name,
      BOT_MODEL_TYPE: modelType.toString().split(".")[1],
      BOT_PROMPT: prompt,
      BOT_TEMPERATURE: 0.5,
      BOT_IS_PRIVATE: isPrivate ?? true,
      BOT_ACTIVE: true,
      BOT_PROFILE_PHOTO: photoUrl,
      CREATED_AT: getDateTimeEpoch(),
      UPDATED_AT: getDateTimeEpoch(),
    };

    final dio = await auth.getDio();
    final response = await dio.post(url, data: payload);
    return Bot.fromDocument(response.data);
  }

  Future<Bot> getBot({
    required botId,
  }) async {
    String url = '${baseUri}machi?botId=$botId';
    final response = await auth.retryGetRequest(url);
    final getData = response.data;

    return Bot.fromDocument(getData);
  }

  Future<Bot> updateBot({
    required botId,
    required Map<String, dynamic> data,
    required ValueSetter onSuccess,
    required Function(String) onError,
  }) async {
    String url = '${baseUri}bot';
    final dio = await auth.getDio();
    final response = await dio.put(url, data: {...data, botId: botId});
    final getData = response.data;
    return Bot.fromDocument(getData);
  }

  Future<List<Bot>> getAllBots(
      {required int page,
      required BotModelType modelType,
      String? search,
      CancelToken? cancelToken}) async {
    String url =
        '${baseUri}get_all?page=$page${search != null ? "&search=$search" : ""}';
    final response = await auth.retryGetRequest(url, cancelToken: cancelToken);
    final getData = response.data;

    List<Bot> result = [];
    for (var data in getData) {
      result.add(Bot.fromDocument(data));
    }

    return result;
  }

  Future<List<Bot>> getMyCreatedBots() async {
    String url = '${baseUri}get_my_creation';
    final response = await auth.retryGetRequest(url);
    final getData = response.data;

    return getData.toJson();
  }

  Future<List<Bot>> myAddedMachi() async {
    String url = '${baseUri}user_added_machi';
    final response = await auth.retryGetRequest(url);
    final getData = response.data;

    List<Bot> botList = [];
    for (var data in getData) {
      botList.add(Bot.fromDocument(data));
    }

    return botList;
  }

  Future<String> machiHelper(
      {required text, required action, CancelToken? cancelToken}) async {
    String url = '${baseUri}machi_helper';
    final dio = await auth.getDio();
    final response = await dio.post(url,
        data: {"text": text, "action": action}, cancelToken: cancelToken);
    return response.data;
  }

  Future<List<dynamic>> machiImage(
      {required String text,
      required int numImages,
      bool? isSubscribed,
      CancelToken? cancelToken}) async {
    String url = '${baseUri}machi_image';
    final dio = await auth.getDio();
    final response = await dio.post(url,
        data: {
          "text": text,
          "numImages": numImages,
          "subscribe": isSubscribed ?? false
        },
        cancelToken: cancelToken);
    return response.data;
  }

  Future<String> uploadImageUrl({required uri, required pathLocation}) async {
    String url = '${baseUri}upload_url';
    final dio = await auth.getDio();
    final response =
        await dio.post(url, data: {"url": uri, "path": pathLocation});
    return response.data;
  }
}
