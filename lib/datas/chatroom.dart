import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/bot.dart';

class Chatroom {
  /// Using types and Chatroom together
  final Bot bot;
  final List<types.User>? blockedUsers;
  final String chatroomId;
  final String creatorUser;
  final int createdAt;
  final String roomType;
  bool? isTyping;
  final List<types.Message> messages;
  final String? title;
  final bool? read;
  final int updatedAt;
  final List<types.User> users;
  int pageOffset;

  Chatroom(
      {required this.chatroomId,
      required this.bot,
      required this.createdAt,
      required this.updatedAt,
      required this.roomType,
      required this.messages,
      required this.users,
      required this.creatorUser,
      this.isTyping,
      this.read,
      this.blockedUsers,
      this.title,
      this.pageOffset = 1});

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
      user['id'] = user[USER_ID];
      user['firstName'] = user[USER_USERNAME];
      user['imageUrl'] = user[USER_PROFILE_PHOTO];
      users.add(types.User.fromJson(user));
    });

    /// convert messages to types.Message
    /// note: can't call function, but it is same as message_api _createTypeMessages
    List<types.Message> messages = [];
    if (doc.containsKey('messages')) {
      doc['messages'].forEach((message) {
        types.Message finalMessage;
        types.User? photo = users
            .firstWhereOrNull((user) => user.id == message[CHAT_AUTHOR_ID]);
        final author = types.User(
            id: message[CHAT_AUTHOR_ID] as String,
            firstName: message[CHAT_USER_NAME] ?? "Frankie",
            imageUrl: photo?.imageUrl,
            metadata: message[CHAT_AUTHOR_ID].contains("Machi_")
                ? {"showMeta": true}
                : null);
        message[CHAT_AUTHOR] = author.toJson();
        message[FLUTTER_UI_ID] = message[CHAT_MESSAGE_ID];
        message[CREATED_AT] = message[CREATED_AT]?.toInt();

        if (message[CHAT_TYPE] == CHAT_IMAGE) {
          message['size'] = message[MESSAGE_IMAGE][MESSAGE_IMAGE_SIZE];
          message['height'] = message[MESSAGE_IMAGE][MESSAGE_IMAGE_HEIGHT];
          message['width'] = message[MESSAGE_IMAGE][MESSAGE_IMAGE_WIDTH];
          message['uri'] = message[MESSAGE_IMAGE][MESSAGE_IMAGE_URI];
          message["metadata"] = message[CHAT_TEXT].isNotEmpty &&
                  message[CHAT_TEXT].contains(SLASH_IMAGINE) == false
              ? {"caption": message[CHAT_TEXT]}
              : message[CHAT_TEXT] != null
                  ? {"text": message[CHAT_TEXT]}
                  : null;
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
        isTyping: false,
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt(),
        roomType: doc[ROOM_TYPE],
        read: doc[MESSAGE_READ]);
  }
}
