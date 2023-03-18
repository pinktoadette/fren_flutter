import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chat_controller.dart';
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

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  /// saves user message to backend, backend will save bot response automatically
  /// will automatically create a new room if not provided
  Future<void> saveChatMessage(dynamic partialMessage) async {
    final ChatController chatController = Get.find();
    // save will always be user, because backend will already save bot;
    types.Message? message;
    types.User user = chatController.chatUser;

    if (partialMessage is types.PartialCustom) {
      message = types.CustomMessage.fromPartial(
        author: types.User(id: user.id),
        id: '',
        partialCustom: partialMessage,
      );
    } else if (partialMessage is types.PartialFile) {
      message = types.FileMessage.fromPartial(
        author:types.User(id: user.id),
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

    if (message != null ) {
      final messageMap = message.toJson();
      messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
      messageMap['authorId'] = user.id;
      messageMap[CREATED_AT] = dateTime.millisecondsSinceEpoch;
      messageMap['name'] = user.firstName;
      messageMap[ROOM_ID] = chatController.room.id;
      messageMap[ROOM_HAS_MESSAGES] = true;

      // sends to state
      types.Message msg = _createTypesMessages(messageMap);
      chatController.addMessage(msg);

      // get and save bot side
      await getBotResponse(messageMap);

      // saves user message to remote
      // it is saved when ask for bot response

      // save user message to local
      final DatabaseService _databaseService = DatabaseService();
      await _databaseService.insertChat({...messageMap, "botId": botControl.bot.botId });


    }
  }

  Future getBotResponse(messageMap) async {
    String botId = botControl.bot.botId;
    ChatController chatController = Get.find();

    // save to machi api
    String url = '${baseUri}machi_bot';
    try {
      final dio = await auth.getDio();
      final response = await dio.post(
          url, data: { ...messageMap, "botId": botId, "limit": 3, "roomId": chatController.room.id});

      print (response.data);
      // will contain a roomId
      Map<String, dynamic> newMessage = Map.from(response.data);
      newMessage['text'] = newMessage['text'];
      newMessage['type'] = newMessage['type'];
      types.Message msg = _createTypesMessages(newMessage);
      chatController.addMessage(msg);

      // save to local db
      syncMessages(newMessage);

    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<List<types.Message>> getMessages(int start, int limit) async{
    final ChatController chatController = Get.find();
    Bot bot = botControl.bot;

    String url = '${baseUri}get_last'; // get last n messages
    debugPrint ("Requesting URL $url");
    final dioRequest = await auth.getDio();
    final response = await dioRequest.post(url, data: { "botId": bot.botId, "start": start, "limit": limit });
    List<dynamic> oldMessages = response.data;

    if (oldMessages.isEmpty) {
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

    final List<types.Message> finalMessages = [];
    for (var element in oldMessages) {
      Map<String, dynamic> newMessage = Map.from(element);
      newMessage['text'] = newMessage['text'];
      newMessage['type'] = newMessage['type'];
      types.Message msg = _createTypesMessages(newMessage);
      finalMessages.add(msg);

      // sync to local db
      newMessage['botId'] = bot.botId;
      syncMessages(newMessage);
    }
    return finalMessages;
  }

  Future<List<types.Message>> getLocalDbMessages() async {
    /// get local messages
    Bot bot = botControl.bot;
    final DatabaseService _databaseService = DatabaseService();
    final List<Map<String, dynamic>> messages = await _databaseService.getLastMessages(bot.botId);
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
    /// helper to create types.messsages from local db and remote db
    final author = types.User(id: message['authorId'] as String, firstName: message['name'] ?? "Frankie");
    message['author'] = author.toJson();
    message['id'] = message['id'].toString();
    message['createdAt'] = message['createdAt']?.toInt();

    if (message['type'] == 'image') {
      return types.ImageMessage.fromJson(message);
    }
    return types.Message.fromJson(message);
  }

  Future<void> syncMessages(Map<String, dynamic> messages) async {
    /// if timestamp don't match between local and remote, then sync to remote
    final DatabaseService _databaseService = DatabaseService();
    await _databaseService.insertChat(messages);
  }


}