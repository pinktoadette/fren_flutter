import 'package:machi_app/api/machi/chatroom_api.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/datas/chatroom.dart';
import 'package:machi_app/screens/bot/bot_chat.dart';
import 'package:get/get.dart';
import 'package:machi_app/datas/bot.dart';

class SetCurrentRoom {
  ChatController chatController = Get.find(tag: 'chatroom');
  BotController botController = Get.find(tag: 'bot');
  final _chatroomApi = ChatroomMachiApi();

  void setNewBotRoom(
      {required Bot bot, required bool createNew, bool? closeBack}) async {
    /// create new room and bot
    /// Adds to the end of the list
    botController.bot = bot;
    if (createNew == true) {
      await _chatroomApi.createNewRoom();
    }
    chatController.addEmptyRoomToList();
    chatController.onLoadCurrentRoom(chatController.emptyRoom);

    if (closeBack == true) {
      Get.back();
    }

    Get.to(() => const BotChatScreen(), arguments: {
      "room": chatController.currentRoom,
    });
  }

  /// in conversation tab
  /// updates the room to read on roomlist index
  /// sets current bot to onClicked bot
  void updateRoomAsCurrentRoom(Chatroom room, int index) async {
    chatController.currentRoom = room;
    botController.bot = room.bot;
    chatController.updateRoom(room);

    Get.to(() => (const BotChatScreen()), arguments: {"room": room});
  }
}
