import 'dart:async';
import 'dart:developer';

import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/chatroom.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// Message controller controls the message in the current active room
// Message controller receives initial message from chatroom controller
// New messages are then add to here and updates in chat controller
// @todo maybe don't need two places to update
class MessageController extends GetxController implements GetxService {
  RxList<types.Message> _messages = <types.Message>[].obs;
  late Rx<Chatroom> _currentRoom;

  // get every 10, starting at 10, since 10 is default
  int offset = 1; // inital chatroom load first 10, therefore go to page 1
  int limitPage = PAGE_CHAT_LIMIT;

  Chatroom get currentRoom => _currentRoom.value;
  set currentRoom(Chatroom value) => _currentRoom.value = value;

  // messages in the chatroom
  Stream<List<types.Message>> get streamMessages async* {
    yield _messages;
  }

  // current chatroom
  Stream<Chatroom> get streamRoom async* {
    yield currentRoom;
  }

  @override
  void onInit() async {
    log("Messages initialized");
    super.onInit();
  }

  void addOldMessages(List<types.Message> messages) {
    final RxList<types.Message> rxMessages = messages.obs;
    _messages.addAll(rxMessages);
    _messages.refresh();
  }

  void addMessagesToCurrent(types.Message message) {
    _messages.insert(0, message);
  }

  void onCurrentRoom(List<types.Message> messages) {
    _messages = messages.obs;
  }
}
