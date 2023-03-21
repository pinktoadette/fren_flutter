
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chat_controller.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/sqlite/db.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class ChatroomMachiApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find();
  final ChatController chatController = Get.find();
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  ///////////// ROOM ///////////////
  // a room is created when user loads app and compares to remote and local
  // if none exists, create one.
  // creates a new room with empty messages in quick chat
  // this way user doesn't need to wait on bot response
  Future<Map<String, dynamic>> createNewRoom() async {
    /// creates a new room
    String url = '${baseUri}chatroom/create_chatroom';
    debugPrint ("Requesting URL $url {botId: ${botControl.bot.botId} }");
    final dioRequest = await auth.getDio();
    final response = await dioRequest.post(url, data: { "botId": botControl.bot.botId, "roomType": "groups" });
    if (response.statusCode == 200 ) {
      final roomData = response.data;
      print (roomData);

      // create a new room
      Chatroom room = Chatroom.fromJson(roomData);
      chatController.onCreateRoomList(room);

      /// save to local db
      final DatabaseService _databaseService = DatabaseService();
      await _databaseService.insertRoom(roomData);

      return roomData;
    }
    print (response.toString());
    return {};
  }

  Future<List<Chatroom>> getAllMyRooms() async {
    String url = '${baseUri}chatroom/users_chatrooms';
    debugPrint ("Requesting URL $url");
    final dioRequest = await auth.getDio();
    final response = await dioRequest.get(url);
    final roomData = response.data;

    // map to types.Room
    // then send to state controller
    // will load in conversation tab
    List<Chatroom> myRooms = [];
    roomData.forEach((room){
      Chatroom myRoom = Chatroom.fromJson(room);
      chatController.onCreateRoomList(myRoom);
      myRooms.add(myRoom);
    });

    return myRooms;
  }

}