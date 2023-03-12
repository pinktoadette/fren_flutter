import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ExternalBotApi {
  // final baseUri = 'https://fin-pyapi.vercel.app/api/';
  final baseUri = 'https://machi.herokuapp.com/api/';
  final BotController botControl = Get.find();

  Future<dynamic> getBotPrompt(String domain, String repoId, String inputs) async {
    String url = '${baseUri}machi_bot';
    Map<String, String> data = {"domain": domain, "model": "train_data", "prompt": inputs};

    print (botControl.bot.botId);
    if (botControl.bot.botId == DEFAULT_BOT_ID) {
      url = '${baseUri}huggable_bot';
      data = {"domain": domain, "model": "facebook/blenderbot-400M-distill", "prompt": inputs};
    }

    //@todo need catch error
    final dio = Dio();
    dio.options.headers['Accept'] = '*/*';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["api-key"] = "3e27dcb9-5c20-4658-abd2-fe333ae7721a";
    dio.options.followRedirects = false;
    final response = await dio.post(url, data: data);

    if (botControl.bot.botId == DEFAULT_BOT_ID) {
      String jsonsDataString = response.toString(); // toString of Response's body is assigned to jsonDataString
      final _data = jsonDecode(jsonsDataString);
      return _data!['generated_text'];
    }

    return response.data;
  }

}
