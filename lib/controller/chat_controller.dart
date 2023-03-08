import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fren_app/api/py_api.dart';
import 'package:fren_app/controller/user_controller.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:get/get.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  late Rx<types.User> _chatUser;
  late Rx<types.User> _chatBot;
  RxList<types.Message> _messages = <types.Message>[].obs;
  late List<BotPrompt> _prompts;
  final _externalBotApi = ExternalBotApi();

  String? error;
  bool isLoading = false;
  bool isInitial = false;
  bool isTest = false;
  bool _retrieveAPI = false;
  int _counter = 0;

  types.User get chatUser => _chatUser.value;
  set chatUser(types.User value) => _chatUser.value = value;
  set pchatUser(types.User value) => _chatUser.value = value;

  types.User get chatBot => _chatBot.value;
  set chatBot(types.User value) => _chatBot.value = value;

  List<types.Message> get messages => _messages;
  set messages(List<types.Message> value) => _messages.value = value;

  @override
  void onInit() async {
    //@todo need to move scope model to getx
    onChatLoad();
    super.onInit();
  }

  void onChatLoad() {
    isLoading = true;
    final BotController botController = Get.find(); // current bot
    final UserController userController = Get.find(); // current user
    debugPrint(" in chat controller ");
    _chatUser = types.User(
      id: userController.user.userId,
      firstName: userController.user.userFullname,
    ).obs;
    _chatBot = types.User(
      id: botController.bot.botId,
      firstName: botController.bot.name,
    ).obs;

    if (isInitial == true) {
      _loadIntro();
    }
    isLoading = false;
  }

  void addMessage(types.Message message) {
    _messages.insert(0, message);
  }

  Future<void> _loadIntro() async {
    final data = await rootBundle.loadString('assets/json/botIntro.json');
    final List<BotPrompt> prompt = jsonDecode(data);
    _prompts = prompt;
    _setIntroMessages();
  }

  Future<void> _setIntroMessages() async {
    types.TextMessage message =
        createMessage(_prompts[_counter].text, _chatBot.value);
    addMessage(message);
    if (_prompts[_counter].hasNext) {
      waitTask(_prompts[_counter].wait > 0 ? _prompts[_counter].wait : 10);
      _counter++;
      _setIntroMessages();
    } else {
      _retrieveAPI = true;
    }
  }

  types.TextMessage createMessage(String text, types.User user) {
    final textMessage = types.TextMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );
    return textMessage;
  }

  void waitTask(int seconds) async {
    Timer(Duration(seconds: seconds), () => debugPrint('done waiting'));
  }

  void handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );
    _messages[index] = updatedMessage;
  }

  void handleSendPressed(types.PartialText message) {
    types.TextMessage textMessage =
        createMessage(message.text, _chatUser.value);
    addMessage(textMessage);
    _callAPI(message.text);
  }

  void handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          messages[index] = updatedMessage;

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );
          messages[index] = updatedMessage;
        }
      }
    }
  }

  Future<void> _callAPI(String message) async {
    final BotController bot = Get.find();

    /// call bot model api
    String response = await _externalBotApi.getBotPrompt(
        bot.bot.domain, bot.bot.repoId, message);
    types.TextMessage textMessage = createMessage(response, _chatBot.value);
    addMessage(textMessage);
  }
}
