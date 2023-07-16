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

  void setNewBotRoom(Bot bot, bool createNew) async {
    /// create new room and bot
    /// Adds to the end of the list
    botController.bot = bot;
    if (createNew == true) {
      await _chatroomApi.createNewRoom();
    }
    chatController.addEmptyRoomToList();
    chatController.onLoadCurrentRoom(chatController.emptyRoom);
    Get.to(() => const BotChatScreen(), arguments: {
      "room": chatController.currentRoom,
      "index": chatController.roomlist.length - 1
    });
  }

  /// in conversation tab
  /// updates the room to read on roomlist index
  /// sets current bot to onClicked bot
  void updateRoomAsCurrentRoom(Chatroom room, int index) async {
    chatController.currentRoom = room;
    botController.bot = room.bot;
    chatController.updateRoom(room);

    Get.to(() => (const BotChatScreen()),
        arguments: {"room": room, 'index': index});
  }
}
