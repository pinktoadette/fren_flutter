import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fren_app/api/conversations_api.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/user_controller.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:async/async.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import 'firechat/firechat_utils.dart';

class MessagesApi {
  /// FINAL VARIABLES
  ///
  final _firestore = FirebaseFirestore.instance;
  final _conversationsApi = ConversationsApi();
  final BotController botController = Get.find();
  final UserController userController = Get.find();

  /// Get stream messages for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String withUserId) {
    return _firestore
        .collection(C_MESSAGES)
        .doc(UserModel().user.userId)
        .collection(withUserId)
        .orderBy(TIMESTAMP)
        .snapshots();
  }

  /// Save chat message
  Future<void> saveMessage({
    required String type,
    required String senderId,
    required String receiverId,
    required String fromUserId,
    required String userPhotoLink,
    required String userFullName,
    required String textMsg,
    required String imgLink,
    required bool isRead,
  }) async {
    /// Save message
    await _firestore
        .collection(C_MESSAGES)
        .doc(senderId)
        .collection(receiverId)
        .doc()
        .set(<String, dynamic>{
      USER_ID: fromUserId,
      MESSAGE_TYPE: type,
      MESSAGE_TEXT: textMsg,
      MESSAGE_IMG_LINK: imgLink,
      TIMESTAMP: FieldValue.serverTimestamp(),
    });

    /// Save last conversation
    await _conversationsApi.saveConversation(
        type: type,
        senderId: senderId,
        receiverId: receiverId,
        userPhotoLink: userPhotoLink,
        userFullName: userFullName,
        textMsg: textMsg,
        isRead: isRead);
  }

  /// Delete current user chat
  Future<void> deleteChat(String withUserId, {bool isDoubleDel = false}) async {
    /// Get Chat for current user
    ///
    final List<DocumentSnapshot<Map<String, dynamic>>> _messages01 =
        (await _firestore
                .collection(C_MESSAGES)
                .doc(UserModel().user.userId)
                .collection(withUserId)
                .get())
            .docs;

    // Check messages sent by current user to be deleted
    if (_messages01.isNotEmpty) {
      // Loop messages to be deleted
      for (var msg in _messages01) {
        // Check msg type
        if (msg[MESSAGE_TYPE] == 'image' &&
            msg[USER_ID] == UserModel().user.userId) {
          /// Delete uploaded images by current user
          await FirebaseStorage.instance
              .refFromURL(msg[MESSAGE_IMG_LINK])
              .delete();
        }
        await msg.reference.delete();
      }

      // Delete current user conversation
      if (!isDoubleDel) {
        _conversationsApi.deleteConverce(withUserId);
      }
    }

    /// Check param
    if (isDoubleDel) {
      /// Get messages sent by onother user to be deleted
      final List<DocumentSnapshot<Map<String, dynamic>>> _messages02 =
          (await _firestore
                  .collection(C_MESSAGES)
                  .doc(withUserId)
                  .collection(UserModel().user.userId)
                  .get())
              .docs;

      // Check messages
      if (_messages02.isNotEmpty) {
        // Loop messages to be deleted
        for (var msg in _messages02) {
          // Check msg type
          if (msg[MESSAGE_TYPE] == 'image' && msg[USER_ID] == withUserId) {
            /// Delete uploaded images by onother user
            await FirebaseStorage.instance
                .refFromURL(msg[MESSAGE_IMG_LINK])
                .delete();
          }
          await msg.reference.delete();
        }
      }
    }
  }



  /// Get or create chat messages
  /// User -> Bots -> messages
  Future getOrCreateChatMessages() async {
    String botId = botController.bot.botId;
    var query = await _firestore
        .collection(C_CHATROOM)
        .doc(UserModel().user.userId)
        .collection(botId)
        .limit(1).get();

    if (query.docs.isEmpty) {
       await _firestore
          .collection(C_CHATROOM)
          .doc(UserModel().user.userId)
          .collection(botId)
          .add({
            "authorId": botId,
            "name": botController.bot.name,
            "createdAt": FieldValue.serverTimestamp(),
            "id": const Uuid().v4(),
            "text": "Hi! I'm ${botController.bot.name}. \n${botController.bot.about}"
          });
    }
  }

  /// Save messages as flutter-chat-ui structure except for author
  /// the structure will always have user => bot
  /// @todo handle error
  Future<void> saveChatMessage(types.TextMessage message) async {

    await _firestore
        .collection(C_CHATROOM)
        .doc(UserModel().user.userId)
        .collection(botController.bot.botId)
        .add(<String, dynamic>{
          "authorId": message.author.id,
          "name": message.author.firstName,
          "createdAt": FieldValue.serverTimestamp(),
          "id": message.id,
          "text": message.text
        });
  }

  /// Get messages based on flutter-chat-ui structure. Will not need to stream because it is already in state
  /// @todo pagination
  Stream<List<types.Message>> getChatMessages({
    List<Object?>? endAt,
    List<Object?>? endBefore,
    int? limit,
    List<Object?>? startAfter,
    List<Object?>? startAt,
  }) {

    var query = _firestore
        .collection(C_CHATROOM)
        .doc(UserModel().user.userId)
        .collection(botController.bot.botId)
        .orderBy("createdAt", descending: true);

    if (endAt != null) {
      query = query.endAt(endAt);
    }

    if (endBefore != null) {
      query = query.endBefore(endBefore);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfter(startAfter);
    }

    if (startAt != null) {
      query = query.startAt(startAt);
    }

    return query.snapshots().map(
            (snapshot) => snapshot.docs.fold<List<types.Message>>(
            [],
                (previousValue, doc) {
      final data = doc.data();
      final author = types.User(id: data['authorId'] as String, firstName: data['name']);

      data['author'] = author.toJson();
      data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
      data['id'] = doc.id;
      data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;
      data['text'] = data['text'];
      print ("??????????????????????");
      print (data);
      return [...previousValue, types.Message.fromJson(data)];
    }));
  }
}
