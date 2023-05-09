import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';

/// formats partial messages to map string dynamic to pass to api
Map<String, dynamic> formatChatMessage(dynamic partialMessage, [uri]) {
  final ChatController chatController = Get.find(tag: 'chatroom');
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

  final messageMap = message.toJson();
  messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
  if (partialMessage is types.PartialImage) {
    messageMap[MESSAGE_IMAGE] = {...messageMap, MESSAGE_IMAGE_URI: uri};
    messageMap.removeWhere((key, value) =>
        key == 'size' ||
        key == 'height' ||
        key == 'width' ||
        key == 'uri' ||
        key == 'name');
  }

  messageMap[CHAT_AUTHOR_ID] = user.id;
  messageMap[CREATED_AT] = getDateTimeEpoch();
  messageMap[CHAT_USER_NAME] = user.firstName;
  messageMap[ROOM_ID] = chatController.currentRoom.chatroomId;
  messageMap[ROOM_HAS_MESSAGES] = true;
  messageMap[CHAT_MESSAGE_ID] = const Uuid().v4().replaceAll(RegExp('/-/'), '');

  return messageMap;
}

/// Helper function to define old messages
/// does not have partial message because it is coming from api
types.Message messageFromJson(Map<String, dynamic> message) {
  final author = types.User(
      id: message[CHAT_AUTHOR_ID] as String,
      firstName: message[CHAT_USER_NAME] ?? "Frankie");
  message[CHAT_AUTHOR] = author.toJson();
  message[FLUTTER_UI_ID] = message[CHAT_MESSAGE_ID];
  message[CREATED_AT] = message[CREATED_AT]?.toInt();

  if (message[CHAT_TYPE] == CHAT_IMAGE) {
    // @todo at two places in chatroom model too
    message['size'] = message[MESSAGE_IMAGE][MESSAGE_IMAGE_SIZE];
    message['height'] = message[MESSAGE_IMAGE][MESSAGE_IMAGE_HEIGHT];
    message['width'] = message[MESSAGE_IMAGE][MESSAGE_IMAGE_WIDTH];
    message['uri'] = message[MESSAGE_IMAGE][MESSAGE_IMAGE_URI];
    return types.ImageMessage.fromJson(message);
  }
  return types.Message.fromJson(message);
}

Future<Map<String, dynamic>> formatStoryboard(Scene customMessage) async {
  String localFlag = 'LOCAL';

  Map<String, dynamic> mapScene = customMessage.toJSON();
  var additional = mapScene["message"];

  if (customMessage.messages.id.contains(localFlag) == true) {
    switch (customMessage.messages.type) {
      case (types.MessageType.text):
        additional = {
          STORY_MESSAGE_TEXT: mapScene["message"]["text"],
          STORY_MESSAGE_TYPE: STORY_MESSAGE_TEXT
        };
        break;
      case (types.MessageType.image):
        String uuid = const Uuid().v4();
        String photoUrl = await uploadFile(
          file: mapScene["message"]["uri"],
          category: 'board',
          categoryId: uuid.replaceAll(RegExp(r'-'), ''),
        );

        additional = {
          'size': 19345,
          'height': 512,
          'width': 512,
          STORY_MESSAGE_TYPE: STORY_MESSAGE_IMAGE,
          STORY_MESSAGE_URI: photoUrl,
        };
        break;
      // @todo
      case types.MessageType.audio:
      case types.MessageType.custom:
      case types.MessageType.file:
      case types.MessageType.system:
      case types.MessageType.unsupported:
      case types.MessageType.video:
        break;
    }
  }

  return {
    STORY_SCENE_SEQ: customMessage.seq,
    STORY_SCENE_ID: customMessage.sceneId,
    STORY_MESSAGES: {
      ...additional,
      CHAT_USER_NAME: customMessage.messages.author.firstName,
    }
  };
}
