import 'dart:developer';

import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';

// Message controller controls the message in the current active room
// Message controller receives initial message from chatroom controller
// New messages are then add to here and updates in chat controller
// @todo maybe don't need two places to update
class MessageController extends GetxController implements GetxService {
  // get every 10, starting at 10, since 10 is default
  int offset = 1; // inital chatroom load first 10, therefore go to page 1
  int limitPage = PAGE_CHAT_LIMIT;

  // messages in the chatroom
  // Stream<List<types.Message>> get streamMessages async* {
  //   yield _messages;
  // }

  // // current chatroom
  // Stream<Chatroom> get streamRoom async* {
  //   yield currentRoom;
  // }

  @override
  void onInit() async {
    log("Messages initialized");
    super.onInit();
  }
}
