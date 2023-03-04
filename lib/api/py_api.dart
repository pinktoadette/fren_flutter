import 'dart:convert';
import 'dart:io';

import 'package:fren_app/datas/bot.dart';
import 'package:http/http.dart' as http;

class ExternalBotApi {
  final baseUri = 'https://fin-pyapi.vercel.app/api/';
  final Map<String, String> _header = <String, String>{
    "api-key": "3e27dcb9-5c20-4658-abd2-fe333ae7721a",
  };

  Future<BotPrompt> fetchIntroBot(String botId, int index) async {
    final url = '$baseUri/bot_intro?q=$index';
    final res = await http.get(
        Uri.parse(url),
        headers: _header
    );
    print ("bot intro");
    Map<String, dynamic> jsonResponse = jsonDecode(res.body);
    return BotPrompt.fromJson(jsonResponse);
  }

}
