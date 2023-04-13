import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/date_now.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:uuid/uuid.dart';

class BotApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find();
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<void> createBot({
    required name,
    domain,
    subdomain,
    prompt,
    temperature,
    price,
    priceUnit,
    model,
    required modelType,
    required about,
    required ValueSetter onSuccess,
    required Function(String) onError,
  }) async {
    String url = '${baseUri}bot/create_machi';

    var data = {
      BOT_ID: "Machi_$UniqueKey()", // external botId
      BOT_ABOUT: about,
      BOT_NAME: name,
      BOT_MODEL: model,
      BOT_MODEL_TYPE: modelType,
      BOT_DOMAIN: domain,
      BOT_SUBDOMAIN: subdomain,
      BOT_PROMPT: prompt,
      BOT_TEMPERATURE: temperature,
      BOT_PRICE: price ?? 0,
      BOT_PRICE_UNIT: priceUnit,
      BOT_ACTIVE: false,
      BOT_ADMIN_STATUS: 'pending',
      CREATED_AT: getDateTimeEpoch(),
      UPDATED_AT: getDateTimeEpoch(),
    };

    final dio = await auth.getDio();
    dio.post(url, data: {...data}).then((response) async {
      final created = response.data;
      final Bot bot = created.toJson();
      onSuccess(bot);
    }).catchError((onError) {
      debugPrint('createBot() -> error');
      // Callback function
      onError(onError);
    });
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

  Future<List<Bot>> getAllBots(int limit, int offset) async {
    String url = '${baseUri}bot/get_all?limit=$limit&offset=$offset';
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
}
