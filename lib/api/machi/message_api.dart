import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/datas/chatroom.dart';
import 'package:machi_app/helpers/message_format.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

/// Handles all chat messages response and requests.
class MessageMachiApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find(tag: 'bot');
  final auth = AuthApi();
  ChatController chatController = Get.find(tag: 'chatroom');

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  /// saves the user response
  Future<String> saveUserResponse(
      {required Map<String, dynamic> messageMap, String? tags}) async {
    String url = '${baseUri}chat/user_response';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url, data: {
      ...messageMap,
      if (tags != null && tags.isNotEmpty) CHAT_MESSAGE_TAGS: tags
    });
    // returns messageId
    return response.data;
  }

  /// Get task from taskId for background jobs
  Future<Map<String, dynamic>> getTaskResponse(String taskId) async {
    // save to machi api
    String url = '${baseUri}tasks/task/$taskId';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.get(url);
    log("Get task");

    Map<String, dynamic> data = Map.from(response.data);
    return data;
  }

  /// Gets the bot response. It looks up the last message
  /// and responds to that. Bot is already saved in room document
  Future<Map<String, dynamic>> getBotResponse(
      {CancelToken? cancelToken}) async {
    String chatroomId = chatController.currentRoom.chatroomId;

    // save to machi api
    String url = '${baseUri}chat/machi_response';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url,
        data: {ROOM_ID: chatroomId}, cancelToken: cancelToken);
    log("Saved and got bot responses");

    return response.data;
  }

  /// Get paginations for old messages
  Future<List<types.Message>> getMessages() async {
    ChatController chatController = Get.find(tag: 'chatroom');
    Chatroom room = chatController.currentRoom;
    int offset = room.pageOffset;

    String url = '${baseUri}chat/messages'; // get last n messages
    debugPrint(
        "Requesting URL $url  Query params: chatroomId: ${room.chatroomId}, offset: $offset, limit: $PAGE_CHAT_LIMIT");
    final dioRequest = await auth.getDio();
    final response = await dioRequest.get(url, queryParameters: {
      "chatroomId": chatController.currentRoom.chatroomId,
      "offset": offset,
      "limit": PAGE_CHAT_LIMIT
    });
    List<dynamic> oldMessages = response.data;
    List<types.Message> oldList = [];
    if (oldMessages.isNotEmpty) {
      var theseMessage = oldMessages[0]['messages'];
      if (theseMessage.isNotEmpty) {
        for (var element in theseMessage) {
          Map<String, dynamic> newMessage = Map.from(element);
          types.Message msg = messageFromJson(newMessage);
          oldList.add(msg);
        }
        //set the next start page
        chatController.currentRoom.pageOffset += 1;
      }
    }
    chatController.loadOldMessages(messages: oldList);
    return oldList;
  }
}
