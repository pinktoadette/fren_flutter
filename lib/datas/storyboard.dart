import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/constants/constants.dart';

class StoryUser {
  final String userId;
  final String photoUrl;
  final String username;

  StoryUser(
      {required this.userId, required this.photoUrl, required this.username});

  factory StoryUser.fromDocument(Map<String, dynamic> doc) {
    return StoryUser(
        userId: doc[USER_ID],
        photoUrl: doc[USER_PROFILE_PHOTO],
        username: doc[USER_USERNAME]);
  }
}

class Storyboard {
  /// Using types and Chatroom together
  final String title;
  final List<types.Message> messages;
  final StoryUser createdBy;
  final int createdAt;
  final int updatedAt;

  Storyboard(
      {required this.title,
      required this.messages,
      required this.createdBy,
      required this.createdAt,
      required this.updatedAt});

  Storyboard copyWith(
      {String? title,
      List<types.Message>? messages,
      StoryUser? createdBy,
      int? createdAt,
      int? updatedAt}) {
    return Storyboard(
        title: title ?? this.title,
        messages: messages ?? this.messages,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt);
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'title': title,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'messages': messages,
      'createdBy': createdBy
    };
  }

  factory Storyboard.fromJson(Map<String, dynamic> doc) {
    /// get Bot

    StoryUser user = StoryUser.fromDocument(doc[STORY_CREATED_BY]);

    /// convert messages to types.Message
    /// note: can't call function, but it is same as message_api _createTypeMessages
    List<types.Message> messages = [];
    if (doc.containsKey('messages')) {
      doc['messages'].forEach((message) {
        types.Message finalMessage;
        final author = types.User(
            id: message[CHAT_AUTHOR_ID] as String,
            firstName: message[CHAT_USER_NAME] ?? "Frankie",
            imageUrl: message[USER_PROFILE_PHOTO],
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
          finalMessage = types.ImageMessage.fromJson(message);
        } else {
          finalMessage = types.Message.fromJson(message);
        }
        messages.add(finalMessage);
      });
    }

    return Storyboard(
        title: doc[STORY_TITLE],
        createdBy: user,
        messages: messages,
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt());
  }
}
