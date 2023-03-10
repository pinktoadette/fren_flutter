import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:fren_app/api/messages_api.dart';
import 'package:fren_app/controller/user_controller.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:get/get.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  final BotController botController = Get.find();// current bot
  final UserController userController = Get.find(); // current user
  late Rx<types.User> _chatUser;
  late Rx<types.User> _chatBot;
  RxList<types.Message> _messages = <types.Message>[].obs;
  late List<BotPrompt> _prompts;

  final _messagesApi = MessagesApi();

  String? error;
  bool retrieveAPI = true;
  bool isLoading = false;
  bool isInitial = false;
  bool isTest = false;
  int _counter = 0;

  types.User get chatUser => _chatUser.value;
  set chatUser(types.User value) => _chatUser.value = value;

  types.User get chatBot => _chatBot.value;
  set chatBot(types.User value) => _chatBot.value = value;

  List<types.Message> get messages => _messages;
  set messages(List<types.Message> value) => _messages.value = value;

  @override
  void onInit() async {
    _chatUser = types.User(
      id: userController.user.userId,
      firstName: userController.user.userFullname,
    ).obs;

    //@todo need to move scope model to getx
    onChatLoad();
    super.onInit();
  }

  /// load the current bot
  void onChatLoad() {
    _chatBot = types.User(
      id: botController.bot.botId,
      firstName: botController.bot.name,
    ).obs;

    //create or get room id
    _messagesApi.getOrCreateChatMessages();
    //load previous messages to 50
    onLoadFirebaseChat();

    if (isInitial == true) {
      _loadIntro();
    }
  }

  /// load messages from firebase
  /// only loads once, then we take from getx state afterwards
  void onLoadFirebaseChat() async {
    debugPrint("loading fire chat");
    //
    // Stream<List<types.Message>>  msgs =  _messagesApi.getChatMessages();
    // msgs.listen((mgs) {
    //   for (var msg in mgs) {
    //     print (msgs);
    //     addMessage(msg);
    //   }
    // });

  }

  /// add messages
  void addMessage(types.Message message) {
    _messages.insert(0, message);
  }

  /// initial onboard intro to get the data
  Future<void> _loadIntro() async {
    final data = await rootBundle.loadString('assets/json/botIntro.json');
    final List<BotPrompt> prompt = jsonDecode(data);
    _prompts = prompt;
    _setIntroMessages();
  }

  /// gets all prompts until retrieveAPI to get API conversations
  Future<void> _setIntroMessages() async {
    types.TextMessage message =
        createMessage(_prompts[_counter].text, _chatBot.value);
    addMessage(message);
    if (_prompts[_counter].hasNext) {
      waitTask(_prompts[_counter].wait > 0 ? _prompts[_counter].wait : 10);
      _counter++;
      _setIntroMessages();
    } else {
      retrieveAPI = true;
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
}
