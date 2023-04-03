import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/bot.dart';
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
    required ownerId,
    required name,
    required domain,
    required subdomain,
    required prompt,
    required temperature,
    required price,
    required priceUnit,
    required about,
    required ValueSetter onSuccess,
    required Function(String) onError,
  }) async {
    String url = '${baseUri}bot/create_bot';
    String uid = const Uuid().v1().substring(0, 8);

    var data = {
      BOT_ID: "MACHI_$uid", // external botId
      BOT_ABOUT: about,
      BOT_NAME: name,
      BOT_OWNER_ID: ownerId,
      BOT_DOMAIN: domain,
      BOT_SUBDOMAIN: subdomain,
      BOT_PROMPT: prompt,
      BOT_TEMPERATURE: temperature,
      BOT_PRICE: double.parse(price),
      BOT_PRICE_UNIT: priceUnit,
      BOT_ACTIVE: false,
      BOT_ADMIN_STATUS: 'pending',
      CREATED_AT: FieldValue.serverTimestamp(),
      UPDATED_AT: FieldValue.serverTimestamp(),
    };

    final dio = await auth.getDio();
    dio.post(url, data: {...data}).then((response) async {
      final created = response.data;
      final Bot bot = created.toJson();
      onSuccess(bot.botId);
    }).catchError((onError) {
      debugPrint('createBot() -> error');
      // Callback function
      onError(onError);
    });
  }

  Future<Bot> getBot({
    required botId,
    required ValueSetter onSuccess,
    required Function(String) onError,
  }) async {
    String url = '${baseUri}bot/get_bot';
    final dio = await auth.getDio();
    final response = await dio.get(url, data: {botId: botId});
    final getData = response.data;

    return getData.toJson();
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
    return getData.toJson();
  }

  Future<List<Bot>> getAllBotsTrend() async {
    String url = '${baseUri}trending_bots';
    final dio = await auth.getDio();
    final response = await dio.get(url);
    final getData = response.data;

    return getData.toJson();
  }

  Future<List<Bot>> getMyCreatedBots() async {
    String url = '${baseUri}own_created_bot';
    final dio = await auth.getDio();
    final response = await dio.get(url);
    final getData = response.data;

    return getData.toJson();
  }
}
