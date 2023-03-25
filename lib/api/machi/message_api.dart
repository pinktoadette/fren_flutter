import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/controller/message_controller.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/sqlite/db.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:uuid/uuid.dart';

class MessageMachiApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find();
  final auth = AuthApi();
  ChatController chatController = Get.find();
  MessageController messageController = Get.find();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  /// formats partial messages to map string dynamic to pass to api
  /// This should be in utility
  Map<String, dynamic> formatChatMessage(dynamic partialMessage) {
    final ChatController chatController = Get.find();
    // save will always be user, because backend will already save bot;
    late types.Message message;
    types.User user = chatController.chatUser;

    if (partialMessage is types.PartialCustom) {
      message = types.CustomMessage.fromPartial(
        author: types.User(id: user.id),
        id: '',
        partialCustom: partialMessage,
      );
    } else if (partialMessage is types.PartialFile) {
      message = types.FileMessage.fromPartial(
        author: types.User(id: user.id),
        id: '',
        partialFile: partialMessage,
      );
    } else if (partialMessage is types.PartialImage) {
      message = types.ImageMessage.fromPartial(
        author: types.User(id: user.id),
        id: '',
        partialImage: partialMessage,
      );
    } else if (partialMessage is types.PartialText) {
      message = types.TextMessage.fromPartial(
        author: types.User(id: user.id),
        id: '',
        partialText: partialMessage,
      );
    }

    DateTime dateTime = DateTime.now();

    final messageMap = message.toJson();
    messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
    messageMap[CHAT_AUTHOR_ID] = user.id;
    messageMap[CREATED_AT] = dateTime.millisecondsSinceEpoch;
    messageMap[CHAT_USER_NAME] = user.firstName;
    messageMap[ROOM_ID] = chatController.currentRoom.chatroomId;
    messageMap[ROOM_HAS_MESSAGES] = true;
    messageMap[CHAT_MESSAGE_ID] = const Uuid().v4();

    return messageMap;
  }

  /// saves the user response
  Future saveUserResponse(Map<String, dynamic> messageMap) async {
    ChatController chatController = Get.find();
    Bot bot = botControl.bot;

    String url = '${baseUri}chat/user_response';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    return await dio.post(url, data: {
      ...messageMap,
      BOT_ID: bot.botId,
      ROOM_ID: chatController.currentRoom.chatroomId
    });
  }

  /// Gets the bot response. It looks up the last message and responds to that.
  Future<Map<String, dynamic>> getBotResponse(messageMap) async {
    String botId = botControl.bot.botId;
    // save to machi api
    String url = '${baseUri}chat/machi_response';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url, data: {...messageMap, BOT_ID: botId});
    log("Saved and got bot responses");

    Map<String, dynamic> newMessage = Map.from(response.data);
    return newMessage;
  }

  /// Get paginations for old messages
  Future<List<types.Message>> getMessages() async {
    ChatController chatController = Get.find();
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
          types.Message msg = createTypesMessages(newMessage);
          oldList.add(msg);
        }
        //set the next start page
        messageController.offset =
            messageController.limitPage + messageController.offset;
      }
    }
    return oldList;
  }

  /// Helper function to define messages type
  types.Message createTypesMessages(Map<String, dynamic> message) {
    final author = types.User(
        id: message[CHAT_AUTHOR_ID] as String,
        firstName: message[CHAT_USER_NAME] ?? "Frankie");
    message[CHAT_AUTHOR] = author.toJson();
    message[FLUTTER_UI_ID] = message[CHAT_MESSAGE_ID];
    message[CREATED_AT] = message[CREATED_AT]?.toInt();

    if (message[CHAT_TYPE] == CHAT_IMAGE) {
      message['size'] = 256;
      return types.ImageMessage.fromJson(message);
    }
    return types.Message.fromJson(message);
  }

  Future<void> syncMessages(Map<String, dynamic> messages) async {
    /// if timestamp don't match between local and remote, then sync to remote
    final DatabaseService _databaseService = DatabaseService();
    await _databaseService.insertChat(messages);
  }

  Future<List<types.Message>> getLocalDbMessages() async {
    /// get local messages
    Bot bot = botControl.bot;
    final DatabaseService _databaseService = DatabaseService();
    final List<Map<String, dynamic>> messages =
        await _databaseService.getLastMessages(bot.botId);
    final List<types.Message> finalMessages = [];

    for (var element in messages) {
      Map<String, dynamic> newMessage = Map.from(element);
      newMessage['text'] = newMessage['message'];
      newMessage['type'] = newMessage['messageType'];
      types.Message msg = createTypesMessages(newMessage);
      finalMessages.add(msg);
    }
    return finalMessages;
  }
}
