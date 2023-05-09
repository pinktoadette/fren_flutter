import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/datas/chatroom.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class ChatroomMachiApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;

  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  ///////////// ROOM ///////////////
  // a room is created when user loads app.
  // if none exists, create one.
  // creates a new room with empty messages in quick chat
  // this way user doesn't need to wait on bot response
  Future<Map<String, dynamic>> createNewRoom() async {
    final ChatController chatController = Get.find(tag: 'chatroom');
    final BotController botController = Get.find(tag: 'bot');

    /// creates a new room
    String url = '${baseUri}chatroom/create_chatroom';
    debugPrint("Requesting URL $url {botId: ${botController.bot.botId} }");
    final dioRequest = await auth.getDio();
    final response = await dioRequest.post(url,
        data: {"botId": botController.bot.botId, "roomType": "groups"});
    if (response.statusCode == 200) {
      final roomData = response.data;

      // create a new room
      // create a variable for empty room, _emptyroom.
      // if not empty move to roomlist
      // upon exit of room, if there is no messages, then remove from roomlist
      Chatroom room = Chatroom.fromJson(roomData);
      chatController.onCreateRoomList(room);
      chatController.currentRoom = room;
      return roomData;
    }
    debugPrint(response.toString());
    return {};
  }

  Future<List<Chatroom>> getAllMyRooms() async {
    final ChatController chatController = Get.find(tag: 'chatroom');
    String url = '${baseUri}chatroom/users_chatrooms';
    debugPrint("Requesting URL $url");
    final dioRequest = await auth.getDio();
    final response = await dioRequest.get(url);
    final roomData = response.data;
    List<Chatroom> myRooms = [];
    chatController.roomlist.clear();
    chatController.unreadCounter = 0.obs;
    if (response.statusCode == 200) {
      roomData.forEach((room) {
        Chatroom myRoom = Chatroom.fromJson(room);
        chatController.onCreateRoomList(myRoom);
        myRooms.add(myRoom);
      });
    }

    chatController.roomlist.refresh();
    chatController.unreadCounter.refresh();
    return myRooms;
  }

  Future<void> updateRoom(int index, Chatroom room) async {
    final ChatController chatController = Get.find(tag: 'chatroom');
    String url = '${baseUri}chatroom/update_room';
    debugPrint("Requesting URL $url");
    final updateRoom = room.toJSON();
    final dioRequest = await auth.getDio();
    final response = await dioRequest.put(url, data: updateRoom);

    if (response.statusCode == 200) {
      Chatroom updatedRoom = Chatroom.fromJson(updateRoom);
      chatController.updateRoom(index, updatedRoom);
    }
  }

  Future<void> inviteUserRoom(int index, String friendId, Chatroom room) async {
    final ChatController chatController = Get.find(tag: 'chatroom');
    String url = '${baseUri}chatroom/invite_user';
    debugPrint("Requesting URL $url");
    final updateRoom = room.toJSON();
    final dioRequest = await auth.getDio();
    final response =
        await dioRequest.post(url, data: {...updateRoom, "friendId": friendId});

    if (response.statusCode == 200) {
      Chatroom updatedRoom = Chatroom.fromJson(response.data ?? room);
      chatController.updateRoom(index, updatedRoom);
      chatController.onLoadCurrentRoom(updatedRoom);
    }
  }

  Future<void> leaveChatroom(int index, Chatroom room) async {
    String url = '${baseUri}chatroom/leave_chat';
    debugPrint("Requesting URL $url");
    final updateRoom = room.toJSON();
    final dioRequest = await auth.getDio();
    final response = await dioRequest.post(url, data: updateRoom);

    if (response.statusCode == 200) {
      // get all rooms, instead of removing index
      // if we remove index, the position of the rooms will not be correct
      await getAllMyRooms();
    }
  }

  /// Gets the bot response. It looks up the last message and responds to that.
  Future<String> markAsRead(String chatroomId) async {
    // save to machi api
    String url = '${baseUri}chat/read';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url, data: {"chatroomId": chatroomId});

    return response.data;
  }

  ///////// ADD BOT / Trials /////////////////
  Future<Map<String, dynamic>> tryBot() async {
    final ChatController chatController = Get.find(tag: 'chatroom');
    final BotController botController = Get.find(tag: 'bot');

    String url = '${baseUri}trial/machi';
    debugPrint("Requesting URL $url {botId: ${botController.bot.botId} }");
    final dio = await auth.getDio();
    final response =
        await dio.post(url, data: {BOT_ID: botController.bot.botId});

    if (response.statusCode == 200) {
      final roomData = response.data;

      // create a new room
      Chatroom room = Chatroom.fromJson(roomData);
      chatController.addSpecificBotToRoom(room);

      return roomData;
    }
    debugPrint(response.toString());
    return {};
  }
}
