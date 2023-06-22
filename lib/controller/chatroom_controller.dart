import 'dart:async';
import 'dart:math';

import 'package:machi_app/controller/message_controller.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/chatroom.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// Chat controller controls the roomlist and the room
// the user is currently in. Messages will be in message controller
class ChatController extends GetxController implements GetxService {
  final MessageController messageController =
      Get.find(tag: 'message'); // current messages in this room
  final BotController botController = Get.find(tag: 'bot'); // current bot
  final UserController userController = Get.find(tag: 'user'); // current user
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
            imageUrl: UserModel().user.userProfilePhoto)
        .obs;
  }

  void initCurrentRoom() {
    var date = getDateTimeEpoch();
    _currentRoom = Chatroom(
            chatroomId: '',
            bot: Bot(
                category: "General",
                botId: "",
                profilePhoto: "",
                name: "",
                domain: "",
                subdomain: "",
                modelType: BotModelType.prompt,
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
    roomlist.refresh();
  }

  void removeEmptyRoomfromList() {
    roomlist.remove(emptyRoom);
    roomlist.refresh();
  }

  void deleteRoomfromList(Chatroom room) {
    roomlist.removeWhere(((item) => item.chatroomId == room.chatroomId));
    roomlist.refresh();
  }

  /// get/create room with another bot
  void addSpecificBotToRoom(Chatroom room) {
    _currentRoom = room.obs;
    roomlist.add(room);
    roomlist.refresh();
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
    botController.bot = room.bot;
    roomlist[index] = room;
    if (room.read == true) {
      int unread = unreadCounter.value - 1;
      unreadCounter = max(unread, 0).obs;
    }
    roomlist.refresh();
  }

  void sortRoomExit(int currentIndx) {
    Chatroom currentRoom = roomlist[currentIndx];
    roomlist.remove(currentRoom);
    roomlist.insert(0, currentRoom);
  }
}
