import 'package:flutter/cupertino.dart';
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class ChatroomMachiApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find();
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  ///////////// ROOM ///////////////
  // a room is created when user loads app.
  // if none exists, create one.
  // creates a new room with empty messages in quick chat
  // this way user doesn't need to wait on bot response
  Future<Map<String, dynamic>> createNewRoom() async {
    final ChatController chatController = Get.find();

    /// creates a new room
    String url = '${baseUri}chatroom/create_chatroom';
    debugPrint("Requesting URL $url {botId: ${botControl.bot.botId} }");
    final dioRequest = await auth.getDio();
    final response = await dioRequest
        .post(url, data: {"botId": botControl.bot.botId, "roomType": "groups"});
    if (response.statusCode == 200) {
      final roomData = response.data;

      // create a new room
      // create a variable for empty room.
      // if not empty move to roomlist
      Chatroom room = Chatroom.fromJson(roomData);
      chatController.onCreateRoomList(room);

      return roomData;
    }
    debugPrint(response.toString());
    return {};
  }

  Future<List<Chatroom>> getAllMyRooms() async {
    final ChatController chatController = Get.find();
    String url = '${baseUri}chatroom/users_chatrooms';
    debugPrint("Requesting URL $url");
    final dioRequest = await auth.getDio();
    final response = await dioRequest.get(url);
    final roomData = response.data;
    List<Chatroom> myRooms = [];
    chatController.roomlist.clear();

    if (response.statusCode == 200) {
      roomData.forEach((room) {
        Chatroom myRoom = Chatroom.fromJson(room);
        chatController.onCreateRoomList(myRoom);
        myRooms.add(myRoom);
      });
    }
    return myRooms;
  }

  Future<void> updateRoom(int index, Chatroom room) async {
    final ChatController chatController = Get.find();
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
}
