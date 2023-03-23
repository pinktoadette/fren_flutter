
import 'dart:async';

import 'package:fren_app/controller/message_controller.dart';
import 'package:fren_app/controller/user_controller.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;


class ChatController extends GetxController implements GetxService {
  final MessageController messageController = Get.find(); // current messages in this room
  final BotController botController = Get.find();// current bot
  final UserController userController = Get.find(); // current user
  late Rx<types.User> _chatUser;
  late Rx<types.User> _chatBot;

  RxList<Chatroom> _roomlist = <Chatroom>[].obs;
  late Rx<Chatroom> _currentRoom;

  String? error;
  bool retrieveAPI = true;
  bool isLoading = false;
  bool isLoaded = false;
  bool isInitial = false;
  bool isTest = false;

  types.User get chatUser => _chatUser.value;
  set chatUser(types.User value) => _chatUser.value = value;

  types.User get chatBot => _chatBot.value;
  set chatBot(types.User value) => _chatBot.value = value;

  Chatroom get currentRoom => _currentRoom.value;
  set currentRoom(Chatroom value) => _currentRoom.value = value;


  // current chatroom
  Stream<Chatroom> get streamRoom async* {
    yield currentRoom;
  }

  // shows a list of chatrooms in convo tab
  Stream<List<Chatroom>> get streamRoomlist async* {
    yield _roomlist;
  }


  @override
  void onInit() async {
    _chatUser = types.User(
      id: userController.user.userId,
      firstName: userController.user.userFullname,
    ).obs;
    initCurrentRoom();
    super.onInit();
  }

  void initCurrentRoom() {
    _currentRoom = Chatroom(
        chatroomId: '',
        botId: '',
        users: [],
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        roomType: '',
        messages: [],
        creatorUser: ''
    ).obs;
  }

  /// when you create a new room, you're in, therefore you are also in the current room
  /// For conversation tab
  void onCreateRoomList(Chatroom myRooms) {
    if (myRooms.messages.isNotEmpty) {
      _roomlist.add(myRooms);
      _currentRoom = myRooms.obs;
    }
  }


  /// load the current bot
  /// gets called on start up
  void onChatLoad() {
    _chatBot = types.User(
      id: botController.bot.botId,
      firstName: botController.bot.name,
    ).obs;
    print("onChatload");
    isLoaded = true;
  }

  /// add messages to this room as preview / preload
  void addMessage(types.Message message) {
    // _messages.insert(0, message);
    _currentRoom.value.messages.insert(0, message);
  }

  void onLoadCurrentRoom (Chatroom room) {
    currentRoom = room;
    messageController.onCurrentRoom(room.messages);
  }


// Future<void> _fetchLocalMessages() async {
  //   List<types.Message> localMessage = await _messagesApi.getLocalDbMessages();
  //   List<types.Message> lastRemoteMessage = await _messagesApi.getMessages(0, 1);
  //
  //   if (localMessage.isNotEmpty) {
  //     int localTimestamp = localMessage[0].createdAt?.toInt() ?? 0;
  //     if (lastRemoteMessage[0].createdAt! <= localTimestamp ) {
  //       debugPrint("Using db -> local. Message length ${localMessage.length}");
  //       addMultipleMessages(localMessage);
  //       return;
  //     }
  //   }
  //   _fetchRemoteUserMessages();
  // }
  //
  // Future<void> _fetchRemoteUserMessages() async {
  //   List<types.Message> messages = await _messagesApi.getMessages(0, 50);
  //   debugPrint("Using db -> remote. Message length ${messages.length}");
  //   addMultipleMessages(messages);
  // }



}
