import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/controller/message_controller.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/helpers/message_format.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class MessageMachiApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find(tag: 'bot');
  final auth = AuthApi();
  ChatController chatController = Get.find(tag: 'chatroom');
  MessageController messageController = Get.find(tag: 'message');

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  /// saves the user response
  Future<String> saveUserResponse(
      {required Map<String, dynamic> messageMap, String? tags}) async {
    String url = '${baseUri}chat/user_response';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response =
        await dio.post(url, data: {...messageMap, CHAT_MESSAGE_TAGS: tags});
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
  Future<Map<String, dynamic>> getBotResponse() async {
    String chatroomId = chatController.currentRoom.chatroomId;

    // save to machi api
    String url = '${baseUri}chat/machi_response';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url, data: {ROOM_ID: chatroomId});
    log("Saved and got bot responses");

    return response.data;
  }

  /// Get paginations for old messages
  Future<List<types.Message>> getMessages() async {
    ChatController chatController = Get.find(tag: 'chatroom');
    int offset = messageController.offset;
    int limit = messageController.limitPage;

    String url = '${baseUri}chat/messages'; // get last n messages
    debugPrint(
        "Requesting URL $url  Query params: chatroomId: ${chatController.currentRoom.chatroomId}, offset: $offset, limit: $limit");
    final dioRequest = await auth.getDio();
    final response = await dioRequest.get(url, queryParameters: {
      "chatroomId": chatController.currentRoom.chatroomId,
      "offset": offset,
      "limit": limit
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
        messageController.offset =
            messageController.limitPage + messageController.offset;
      }
    }
    return oldList;
  }

  // Future<void> syncMessages(Map<String, dynamic> messages) async {
  //   /// if timestamp don't match between local and remote, then sync to remote
  //   final DatabaseService _databaseService = DatabaseService();
  //   await _databaseService.insertChat(messages);
  // }

  // Future<List<types.Message>> getLocalDbMessages() async {
  //   /// get local messages
  //   Bot bot = botControl.bot;
  //   final DatabaseService _databaseService = DatabaseService();
  //   final List<Map<String, dynamic>> messages =
  //       await _databaseService.getLastMessages(bot.botId);
  //   final List<types.Message> finalMessages = [];

  //   for (var element in messages) {
  //     Map<String, dynamic> newMessage = Map.from(element);
  //     newMessage['text'] = newMessage['message'];
  //     newMessage['type'] = newMessage['messageType'];
  //     types.Message msg = messageFromJson(newMessage);
  //     finalMessages.add(msg);
  //   }
  //   return finalMessages;
  // }
}
