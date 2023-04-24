import 'package:flutter/foundation.dart';
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/date_now.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:uuid/uuid.dart';

class BotApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find(tag: 'bot');
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<Bot> createBot(
      {required name,
      domain,
      subdomain,
      prompt,
      temperature,
      price,
      priceUnit,
      model,
      photoUrl,
      required modelType,
      required about}) async {
    String url = '${baseUri}bot/create_machi';
    String uuid = const Uuid().v4().replaceAll("[\\s\\-()]", "");

    var data = {
      BOT_ID: "Machi_${uuid.substring(0, 10)}", // external botId
      BOT_ABOUT: about,
      BOT_NAME: name,
      BOT_MODEL: model,
      BOT_MODEL_TYPE: modelType.toString().split(".")[1],
      BOT_DOMAIN: domain,
      BOT_SUBDOMAIN: subdomain,
      BOT_PROMPT: prompt,
      BOT_TEMPERATURE: temperature,
      BOT_PRICE: price ?? 0,
      BOT_PRICE_UNIT: priceUnit,
      BOT_ACTIVE: false,
      BOT_PROFILE_PHOTO: photoUrl,
      BOT_ADMIN_STATUS: 'pending',
      CREATED_AT: getDateTimeEpoch(),
      UPDATED_AT: getDateTimeEpoch(),
    };

    final dio = await auth.getDio();
    final response = await dio.post(url, data: {...data});
    return Bot.fromDocument(response.data);
  }

  Future<Bot> getBot({
    required botId,
  }) async {
    String url = '${baseUri}bot/get_machi?botId=$botId';
    final dio = await auth.getDio();
    final response = await dio.get(url);
    final getData = response.data;

    return Bot.fromDocument(getData);
  }

  Future<Bot> updateBot({
    required botId,
    required Map<String, dynamic> data,
    required ValueSetter onSuccess,
    required Function(String) onError,
  }) async {
    String url = '${baseUri}bot/update_bot';
    final dio = await auth.getDio();
    final response = await dio.put(url, data: {...data, botId: botId});
    final getData = response.data;
    return Bot.fromDocument(getData);
  }

  Future<List<Bot>> getAllBots(
      int limit, int offset, BotModelType modelType) async {
    String url =
        '${baseUri}bot/get_all?limit=$limit&offset=$offset&model=${modelType.toString().split('.').last}';
    final dio = await auth.getDio();
    final response = await dio.get(url);
    final getData = response.data;

    List<Bot> result = [];
    for (var data in getData) {
      result.add(Bot.fromDocument(data));
    }

    return result;
  }

  Future<List<Bot>> getMyCreatedBots() async {
    String url = '${baseUri}bot/my_creation';
    final dio = await auth.getDio();
    final response = await dio.get(url);
    final getData = response.data;

    return getData.toJson();
  }

  Future<List<Bot>> addBottoList(String botId) async {
    String url = '${baseUri}bot/add_machi';
    final dio = await auth.getDio();
    final response = await dio.post(url, data: {BOT_ID: botId});
    final getData = response.data;

    return getData.toJson();
  }

  Future<List<Bot>> myAddedMachi() async {
    String url = '${baseUri}bot/user_added_machi';
    final dio = await auth.getDio();
    final response = await dio.get(url);
    final getData = response.data;

    List<Bot> botList = [];
    for (var data in getData) {
      botList.add(Bot.fromDocument(data));
    }

    return botList;
  }
}
