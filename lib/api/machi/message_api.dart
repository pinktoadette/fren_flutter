import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chat_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class MessageApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  // final baseUri = 'https://machi.herokuapp.com/api/';
  final baseUri = 'http://10.0.2.2:8000/api/';
  final BotController botControl = Get.find();
  final ChatController chatController = Get.find();
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  /// saves user message to backend, backend will save bot response automatically
  Future saveChatMessage(dynamic partialMessage) async {
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
      // save will always be user, because backend will already save bot;
      String url = '${baseUri}machi_bo';

      final messageMap = message.toJson();
      messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
      messageMap['authorId'] = user!.id;
      messageMap['createdAt'] = FieldValue.serverTimestamp();
      messageMap['name'] = user.firstName;


      print (messageMap);

      final dio = await auth.getDio();
      final response = await dio.post(url, data: { ...messageMap, "respondToId": botId });

      return response.data;
    }
    return [];
  }


  Future<List<types.Message>> getMessages() async{
    String botId = botControl.bot.botId;

    String url = '${baseUri}get_prompts';
    final dio = await auth.getDio();
    final response = await dio.post(url, data: { botId: botId });

    List<types.Message> listMessage =  response.data.map((message){
      final author = types.User(id: message['authorId'] as String, firstName: message['name']);
      message['author'] = author.toJson();
      message['createdAt'] = message['createdAt']?.millisecondsSinceEpoch;
      message['id'] = message.id;
      message['updatedAt'] = message['updatedAt']?.millisecondsSinceEpoch;

      if (message['type'] == 'image') {
        return types.ImageMessage.fromJson(message);
      }

      return types.Message.fromJson(message);
    });
    return listMessage;
  }

}
