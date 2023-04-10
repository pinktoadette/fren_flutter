import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/bot.dart';

class Chatroom {
  /// Using types and Chatroom together
  final String chatroomId;
  final String? title;
  final String creatorUser;
  final Bot bot;
  final String roomType;
  final List<types.Message> messages;
  final List<types.User> users;
  final List<types.User>? blockedUsers;
  final int createdAt;
  final int updatedAt;
  final bool? read;

  Chatroom(
      {required this.chatroomId,
      required this.bot,
      required this.createdAt,
      required this.updatedAt,
      required this.roomType,
      required this.messages,
      required this.users,
      required this.creatorUser,
      this.read,
      this.blockedUsers,
      this.title});

  Chatroom copyWith(
      {String? chatroomId,
      Bot? bot,
      int? createdAt,
      int? updatedAt,
      String? title,
      List<types.Message>? messages,
      String? roomType,
      bool? read,
      List<types.User>? users}) {
    return Chatroom(
        chatroomId: chatroomId ?? this.chatroomId,
        bot: bot ?? this.bot,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        roomType: roomType ?? this.roomType,
        messages: messages ?? this.messages,
        users: users ?? this.users,
        read: read ?? this.read,
        creatorUser: creatorUser);
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'chatroomId': chatroomId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'roomType': roomType,
      'creatorUser': creatorUser
    };
  }

  factory Chatroom.fromJson(Map<String, dynamic> doc) {
    /// get Bot

    /// convert users to types.Users
    List<types.User> users = [];
    doc['users'].forEach((user) {
      user['id'] = user['userId'];
      user['firstName'] = user['fullname'];
      users.add(types.User.fromJson(user));
    });

    /// convert messages to types.Message
    /// note: can't call function, but it is same as message_api _createTypeMessages
    List<types.Message> messages = [];
    if (doc.containsKey('messages')) {
      doc['messages'].forEach((message) {
        types.Message finalMessage;
        final author = types.User(
            id: message[CHAT_AUTHOR_ID] as String,
            firstName: message[CHAT_USER_NAME] ?? "Frankie");
        message[CHAT_AUTHOR] = author.toJson();
        message[FLUTTER_UI_ID] = message[CHAT_MESSAGE_ID];
        message[CREATED_AT] = message[CREATED_AT]?.toInt();

        if (message[CHAT_TYPE] == CHAT_IMAGE) {
          message['size'] = 256;
          finalMessage = types.ImageMessage.fromJson(message);
        }
        finalMessage = types.Message.fromJson(message);
        messages.add(finalMessage);
      });
    }

    Bot bot = Bot.fromDocument(doc[BOT_INFO]);

    return Chatroom(
        chatroomId: doc[ROOM_ID],
        bot: bot,
        title: doc[ROOM_TITLE],
        creatorUser: doc[ROOM_CREATED_BY],
        users: users,
        messages: messages,
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt(),
        roomType: doc[ROOM_TYPE],
        read: doc[MESSAGE_READ]);
  }
}
