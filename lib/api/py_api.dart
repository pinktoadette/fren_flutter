import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:http/http.dart' as http;

class ExternalBotApi {
  final baseUri = 'https://fin-pyapi.vercel.app/api/';
  final Map<String, String> _header = <String, String>{
    "api-key": "3e27dcb9-5c20-4658-abd2-fe333ae7721a",
    "Accept" : "application/json",
    HttpHeaders.contentTypeHeader: "application/json"
  };

  Future<BotPrompt> fetchIntroBot(String botId, int index) async {
    final url = '$baseUri/bot_intro?q=$index';
    final res = await http.get(
        Uri.parse(url),
        headers: _header
    );
    Map<String, dynamic> jsonResponse = jsonDecode(res.body);
    return BotPrompt.fromJson(jsonResponse);
  }

  Future<Map<String, dynamic>?> getBotPrompt(String repoId, String inputs) async {
    final url = '${baseUri}huggable_bot';
    final data = {"repoId": repoId, "inputs": inputs};

    //@todo need catch error
    final dio = Dio();
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["api-key"] = "3e27dcb9-5c20-4658-abd2-fe333ae7721a";
    dio.options.followRedirects = false;
    final response = await dio.post(url, data: data);

    String jsonsDataString = response.toString(); // toString of Response's body is assigned to jsonDataString
    final _data = jsonDecode(jsonsDataString);
    return _data;
  }

}
