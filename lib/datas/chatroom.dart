import 'dart:ffi';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/models/user_model.dart';

class Chatroom {
  /// Using types and Chatroom together
  final String chatroomId;
  final String? title;
  final String? personality;
  final String creatorUser;
  final String botId;
  final String roomType;
  final List<types.Message> messages;
  final List<types.User> users;
  final List<types.User>? blockedUsers;
  final bool hasMessages; //@todo no need
  final int createdAt;
  final int updatedAt;

  Chatroom({
    required this.chatroomId,
    required this.botId,
    required this.createdAt,
    required this.updatedAt,
    required this.roomType,
    required this.messages,
    required this.users,
    required this.hasMessages,
    required this.creatorUser,
    this.blockedUsers,
    this.title,
    this.personality,
  });

  factory Chatroom.fromJson(Map<String, dynamic> doc) {
    /// convert creator to types.Users

    /// convert users to types.Users
    List<types.User> users = [];
    doc['users'].forEach((user){
      user['id'] = user['uid'];
      user['firstName'] = user['fullname'];
      users.add(types.User.fromJson(user));
    });

    /// convert messages to types.Message
    List<types.Message> messages = [];
    doc['messages'].forEach((message) {
      types.Message finalMessage;
      final author = types.User(id: message[CHAT_AUTHOR_ID] as String, firstName: message[CHAT_USER_NAME] ?? "Frankie");
      message[CHAT_AUTHOR] = author.toJson();
      message[FLUTTER_UI_ID] = message[ROOM_ID].toString();
      message[CREATED_AT] = message[CREATED_AT]?.toInt();

      if (message[CHAT_TYPE] == CHAT_IMAGE) {
         finalMessage = types.ImageMessage.fromJson(message);
      }
      finalMessage = types.Message.fromJson(message);
      messages.add(finalMessage);
    });


    return Chatroom(
        chatroomId: doc['chatroomId'],
        botId: doc['botId'],
        title: doc['title'],
        personality: doc['personality'],
        creatorUser: doc['createdBy'],
        users: users,
        messages: messages,
        createdAt: doc['createdAt'],
        updatedAt: doc['updatedAt'],
        hasMessages: doc['hasMessage'],
        roomType: '',
    );
  }



}