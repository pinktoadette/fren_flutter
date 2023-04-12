import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';

/// formats partial messages to map string dynamic to pass to api
Map<String, dynamic> formatChatMessage(dynamic partialMessage, [uri]) {
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
  messageMap[CREATED_AT] = dateTime.millisecondsSinceEpoch;
  messageMap[CHAT_USER_NAME] = user.firstName;
  messageMap[ROOM_ID] = chatController.currentRoom.chatroomId;
  messageMap[ROOM_HAS_MESSAGES] = true;
  messageMap[CHAT_MESSAGE_ID] = const Uuid().v4();

  return messageMap;
}

/// Helper function to define old messages
/// does not have partial message because it is coming from api
types.Message oldMessageTypes(Map<String, dynamic> message) {
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
