import 'dart:async';
import 'dart:math';

import 'package:fren_app/controller/message_controller.dart';
import 'package:fren_app/controller/user_controller.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// Chat controller controls the roomlist and the room
// the user is currently in. Messages will be in message controller
class ChatController extends GetxController implements GetxService {
  final MessageController messageController =
      Get.find(); // current messages in this room
  final BotController botController = Get.find(); // current bot
  final UserController userController = Get.find(); // current user
  late Rx<types.User> _chatUser;
  late Rx<types.User> _chatBot;

  // ignore: prefer_final_fields
  RxList<Chatroom> roomlist = <Chatroom>[].obs;
  RxInt unreadCounter = 0.obs;
  late Rx<Chatroom> _currentRoom;
  late Rx<Chatroom> _emptyRoom;

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

  Chatroom get emptyRoom => _emptyRoom.value;
  set emptyRoom(Chatroom value) => _emptyRoom.value = value;

  // current chatroom
  Stream<Chatroom> get streamRoom async* {
    yield currentRoom;
  }

  // shows a list of chatrooms in convo tab
  Stream<List<Chatroom>> get streamRoomlist async* {
    yield roomlist;
  }

  @override
  void onInit() async {
    initUser();
    initCurrentRoom();
    super.onInit();
  }

  void initUser() {
    _chatUser = types.User(
      id: UserModel().user.userId,
      firstName: UserModel().user.username,
    ).obs;
  }

  void initCurrentRoom() {
    var date = DateTime.now().millisecondsSinceEpoch;
    _currentRoom = Chatroom(
            chatroomId: '',
            bot: Bot(
                botId: "",
                profilePhoto: "",
                name: "",
                domain: "",
                subdomain: "",
                createdAt: date,
                prompt: "",
                temperature: 0.5,
                about: "",
                updatedAt: date),
            users: [],
            createdAt: date,
            updatedAt: date,
            roomType: '',
            messages: [],
            read: false,
            creatorUser: '')
        .obs;
  }

  /// when you create a new room, user is already in,
  /// therefore you are also in the current room
  void onCreateRoomList(Chatroom myRooms) {
    if (myRooms.messages.isNotEmpty || myRooms.users.length > 1) {
      roomlist.add(myRooms);
      _currentRoom = myRooms.obs;
      if (myRooms.read == false) {
        unreadCounter += 1;
      }
    } else {
      _emptyRoom = myRooms.obs;
    }
  }

  /// when user creates a new empty room
  /// and enters the room, then that room gets added to roomlist
  void addEmptyRoomToList() {
    roomlist.add(emptyRoom);
  }

  void removeEmptyRoomfromList() {
    roomlist.remove(emptyRoom);
  }

  /// load the current bot
  /// gets called on start up
  void onChatLoad() {
    _chatBot = types.User(
      id: botController.bot.botId,
      firstName: botController.bot.name,
    ).obs;
    isLoaded = true;
  }

  /// add messages to this room as preview / preload
  void addMessage(types.Message message) {
    // _messages.insert(0, message);
    _currentRoom.value.messages.insert(0, message);
  }

  // loads current room's message to message controller
  void onLoadCurrentRoom(Chatroom room) {
    currentRoom = room;
    messageController.onCurrentRoom(room.messages);
    roomlist.refresh();
  }

  // update messages from the chatroom, to view once when on convo tab
  void updateMessagesPreview(int index, types.Message message) {
    roomlist[index].messages.insert(0, message);
    roomlist.refresh();
  }

  // update messages from the chatroom, to view once when on convo tab
  void updateRoom(int index, Chatroom room) {
    roomlist[index] = room;
    if (room.read == true) {
      int unread = unreadCounter.value - 1;
      unreadCounter = max(unread, 0).obs;
    }
    roomlist.refresh();
  }
}
