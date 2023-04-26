import 'package:fren_app/api/machi/chatroom_api.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:fren_app/screens/bot/bot_chat.dart';
import 'package:get/get.dart';
import 'package:fren_app/datas/bot.dart';

class SetCurrentRoom {
  ChatController chatController = Get.find(tag: 'chatroom');
  BotController botController = Get.find(tag: 'bot');
  final _chatroomApi = ChatroomMachiApi();

  /// Sets the current room and bot and redirects to the page
  /// Note: there is one more place that does this
  /// bot_profile to try bot
  void setRoom(Bot bot) {
    botController.bot = bot;
    chatController.addEmptyRoomToList();
    chatController.onLoadCurrentRoom(chatController.emptyRoom);
    Get.to(() => const BotChatScreen(), arguments: {
      "room": chatController.emptyRoom,
      "index": chatController.roomlist.length - 1
    });
  }

  /// in conversation tab
  /// updates the room to read on roomlist index
  /// sets current bot to onClicked bot
  void updateRoomReadBot(Chatroom room, int index) async {
    /// mark as read when clicked
    Chatroom updateRoom = room.copyWith(read: true);
    chatController.updateRoom(index, updateRoom);
    await _chatroomApi.markAsRead(room.chatroomId);

    Get.to(() => (const BotChatScreen()),
        arguments: {"room": room, 'index': index});
  }
}
