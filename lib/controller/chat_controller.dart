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
  }

  /// add messages
  void addMessage(types.Message message) {
    _messages.insert(0, message);
  }


}
