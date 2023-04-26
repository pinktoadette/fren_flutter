import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/screens/bot/bot_chat.dart';
import 'package:get/get.dart';
import 'package:fren_app/datas/bot.dart';

class SetCurrentRoom {
  ChatController chatController = Get.find(tag: 'chatroom');
  BotController botController = Get.find(tag: 'bot');

  void setRoom(Bot bot) {
    botController.bot = bot;
    chatController.addEmptyRoomToList();
    chatController.onLoadCurrentRoom(chatController.emptyRoom);
    Get.to(() => const BotChatScreen(), arguments: {
      "room": chatController.emptyRoom,
      "index": chatController.roomlist.length - 1
    });
  }
}
