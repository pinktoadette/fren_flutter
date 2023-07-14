import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/api/machi/message_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/message_controller.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/chatroom.dart';
import 'package:machi_app/helpers/create_uuid.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/helpers/message_format.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:web_socket_channel/web_socket_channel.dart';

// Chat controller controls the roomlist and the room
// the user is currently in. Messages will be in message controller
class ChatController extends GetxController implements GetxService {
  final MessageController messageController =
      Get.find(tag: 'message'); // current messages in this room
  final BotController botController = Get.find(tag: 'bot'); // current bot
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

  final Map<String, WebSocketChannel> _channelMap = {};
  Map<String, Function(List<types.Message>)> _messageListeners = {};

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
    super.onInit();

    initUser();
    initCurrentRoom();
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
    sortRoomExit(index);
    roomlist.refresh();
    update();
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
    update();
  }

  void sortRoomExit(int currentIndx) {
    Chatroom currentRoom = roomlist[currentIndx];
    roomlist.remove(currentRoom);
    roomlist.insert(0, currentRoom);
  }

  //// Socket /////
  /// listens for bot typing in each room
  /// updates the message and typing indicator

  /// open socket
  void onListSocket() {
    for (var room in roomlist) {
      _listenSocket(room);
    }
  }

  /// close socket
  void onCloseSocket() {
    for (var channel in _channelMap.values) {
      channel.sink.close();
    }
  }

  /// Get socket for particular room
  WebSocketChannel? getChannelForChatroom(String chatroomId) {
    return _channelMap[chatroomId];
  }

  /// listen to socket, response back
  Future<void> _listenSocket(Chatroom room) async {
    final _authApi = AuthApi();
    Map<String, dynamic> headers = await _authApi.getHeaders();
    final Uri wsUrl = Uri.parse('${SOCKET_WS}messages/${room.chatroomId}');
    WebSocketChannel channel = WebSocketChannel.connect(wsUrl);
    channel.sink.add(json.encode({"token": headers}));
    _channelMap[room.chatroomId] = channel;

    channel.stream.listen(
      (data) {
        // Handle received data for this channel
        Map<String, dynamic> decodeData = json.decode(data);
        types.Message newMessage = messageFromJson(decodeData["message"]);
        int index = roomlist
            .indexWhere((thisRoom) => thisRoom.chatroomId == room.chatroomId);
        roomlist[index].messages.insert(0, newMessage);
        roomlist.refresh();
        // update();
      },
      onError: (error, s) async {
        // Handle error for this channel
        dynamic response = {
          CHAT_AUTHOR_ID: room.bot.botId,
          CHAT_AUTHOR: room.bot.name,
          BOT_ID: room.bot.botId,
          CHAT_MESSAGE_ID: createUUID(),
          CHAT_TEXT: error.response?.data["message"] ??
              "Sorry, got an error 😕. Try again.",
          CHAT_TYPE: "text",
          CREATED_AT: getDateTimeEpoch()
        };
        channel.sink.add(json.encode({"message": response}));
        await FirebaseCrashlytics.instance.recordError(error, s,
            reason: 'bot has error ${error.toString()}', fatal: true);
      },
    );
  }

  Map<String, dynamic> sendMessage(
      {required Chatroom room, dynamic partialMessage, String? uri}) {
    try {
      Map<String, dynamic> message =
          formatChatMessage(partialMessage: partialMessage, uri: uri);
      WebSocketChannel? channel = _channelMap[room.chatroomId];
      if (channel != null) {
        channel.sink.add(json.encode({"message": message}));
      }
      return message;
    } catch (err) {
      debugPrint(err.toString());
    }
    return {};
  }

  Future<Map<String, dynamic>> getMachiResponse(
      {required Chatroom room}) async {
    final _messageApi = MessageMachiApi();
    int index = roomlist
        .indexWhere((thisRoom) => thisRoom.chatroomId == room.chatroomId);
    roomlist[index].isTyping = true;
    Map<String, dynamic> message = await _messageApi.getBotResponse();
    WebSocketChannel? channel = _channelMap[room.chatroomId];
    if (channel != null) {
      channel.sink.add(json.encode({"message": message}));
    }
    roomlist[index].isTyping = false;
    update();
    return message;
  }
}
