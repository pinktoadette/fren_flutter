import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chat_controller.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/sqlite/connection_db.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:uuid/uuid.dart';

class MessageApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find();
  final ChatController chatController = Get.find();
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  /// saves user message to backend, backend will save bot response automatically
  Future saveChatMessage(dynamic partialMessage) async {
    // save will always be user, because backend will already save bot;
    types.Message? message;
    types.User user = chatController.chatUser;

    if (partialMessage is types.PartialCustom) {
      message = types.CustomMessage.fromPartial(
        author: types.User(id: user!.id),
        id: '',
        partialCustom: partialMessage,
      );
    } else if (partialMessage is types.PartialFile) {
      message = types.FileMessage.fromPartial(
        author: user,
        id: '',
        partialFile: partialMessage,
      );
    } else if (partialMessage is types.PartialImage) {
      message = types.ImageMessage.fromPartial(
        author: types.User(id: user!.id),
        id: '',
        partialImage: partialMessage,
      );
    } else if (partialMessage is types.PartialText) {
      message = types.TextMessage.fromPartial(
        author: types.User(id: user!.id),
        id: '',
        partialText: partialMessage,
      );
    }

    if (message != null) {
      String botId = botControl.bot.botId;
      DateTime dateTime = DateTime.now();

      final messageMap = message.toJson();
      messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
      messageMap['authorId'] = user.id;
      messageMap['createdAt'] = dateTime;
      messageMap['name'] = user.firstName;

      print ({...messageMap, "botId": botId });
      // save to local db
      final DatabaseService _databaseService = DatabaseService();
      await _databaseService.insertChat({...messageMap, "botId": botId });

      // save to machi api
      String url = '${baseUri}machi_bot';
      try {
        final dio = await auth.getDio();
        final response = await dio.post(
            url, data: { ...messageMap, "botId": botId, "createdAt": dateTime.millisecondsSinceEpoch });
        return response.data;
      } catch (error) {
        debugPrint(error.toString());
        rethrow;
      }
    }
    return [];
  }

  Future<List<types.Message>> getMessages(int start, int limit) async{
    Bot bot = botControl.bot;

    String url = '${baseUri}get_prompts'; // get last n messages
    debugPrint ("Requesting URL $url");
    final dioRequest = await auth.getDio();
    final response = await dioRequest.post(url, data: { "botId": bot.botId, "start": start, "limit": limit });
    final oldMessages = response.data;

    if ((oldMessages as List).isEmpty) {
      // create bot first message
      DateTime dateTime = DateTime.now();

      Map<String, dynamic> message = {'author': ''};
      message['authorId'] = bot.botId;
      message['name'] = bot.name;
      message['createdAt'] = dateTime;
      message['id'] = const Uuid().v4();
      message['updatedAt'] = dateTime;
      message['text'] = bot.about;
      message['type'] = "text";

      types.Message fin = _createTypesMessages(message);
      List<types.Message> finalMessage = [];
      finalMessage.add(fin);
      return finalMessage;
    }


    List<types.Message> listMessage =  response.data.map((message){
      return _createTypesMessages(message);
    });
    return listMessage;
  }

  Future<List<types.Message>> getLocalDbMessages() async {
    Bot bot = botControl.bot;
    final DatabaseService _databaseService = DatabaseService();
    final List<Map<String, dynamic>> messages = await _databaseService.getLastMessages(bot.botId);
    print ("lcal get");

    final List<types.Message> finalMessages = [];

    for (var element in messages) {
      Map<String, dynamic> newMessage = Map.from(element);
      newMessage['text'] = newMessage['message'];
      newMessage['type'] = newMessage['messageType'];
      types.Message msg = _createTypesMessages(newMessage);
      finalMessages.add(msg);
    }
    return finalMessages;

  }

  types.Message _createTypesMessages(Map<String, dynamic> message) {
    final author = types.User(id: message['authorId'] as String, firstName: message['name']);
    message['author'] = author.toJson();
    message['id'] = message['id'].toString();

    if (message['createdAt'].runtimeType == DateTime) {
      message['createdAt'] = message['createdAt']?.millisecondsSinceEpoch;
      message['updatedAt'] = message['updatedAt']?.millisecondsSinceEpoch;
    }

    if (message['type'] == 'image') {
      return types.ImageMessage.fromJson(message);
    }
    return types.Message.fromJson(message);
  }



}
