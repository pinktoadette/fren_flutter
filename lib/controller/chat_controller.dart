
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/api/machi/message_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/user_controller.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/socks/socket_manager.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:place_picker/uuid.dart';
import 'package:socket_io_client/socket_io_client.dart';


class ChatController extends GetxController implements GetxService {
  final _socketResponse= StreamController<String>();
  final BotController botController = Get.find();// current bot
  final UserController userController = Get.find(); // current user
  late Rx<types.User> _chatUser;
  late Rx<types.User> _chatBot;

  RxList<types.Message> _messages = <types.Message>[].obs;
  RxList<Chatroom> _roomlist = <Chatroom>[].obs;
  late Rx<Chatroom> _currentRoom;

  String? error;
  bool retrieveAPI = true;
  bool isLoading = false;
  bool isLoaded = false;
  bool isInitial = false;
  bool isTest = false;
  // late Stream<List<types.Message>> _streamMessages;
  final _messagesApi = MessageMachiApi();

  types.User get chatUser => _chatUser.value;
  set chatUser(types.User value) => _chatUser.value = value;

  types.User get chatBot => _chatBot.value;
  set chatBot(types.User value) => _chatBot.value = value;

  Chatroom get currentRoom => _currentRoom.value;
  set currentRoom(Chatroom value) => _currentRoom.value = value;

  // messages in the chatroom
  Stream<List<types.Message>> get streamMessages async* {
    yield _messages;
  }

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
    _listenSocket();
    super.onInit();
  }

  @override
  void dispose() {
    _socketResponse!.sink.close();
    super.dispose();
  }

  Future<void> _listenSocket() async {
    print ("_listen to socket");

    final _authApi = AuthApi();
    StreamSocket streamSocket =StreamSocket();

    Map<String, dynamic> headers = await _authApi.getHeaders();
    Socket socket = io("${SOCKET_WS}chatroom/messages",
        OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders(headers)
            .build());

    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });

    //When an event recieved from server, data is added to the stream
    socket.on('event', (data) => {
      print( "printing socket data received: ${data.toString()}")
    });
    socket.onDisconnect((_) => print('disconnect'));
  }

  /// when you create a new room, you're in, therefore you are also in the current room
  void onCreateRoomList(Chatroom myRooms) {
    _roomlist.add(myRooms);
    _currentRoom = myRooms.obs;
  }

  void onLoadRoomMessages() {
    _messages = _currentRoom.value.messages.obs;
  }

  /// load the current bot
  void onChatLoad() {
    _chatBot = types.User(
      id: botController.bot.botId,
      firstName: botController.bot.name,
    ).obs;
    // fetch local messages
    // then match latest timestamp with last remote message
    // _fetchLocalMessages();
    print("onChatload");
    isLoaded = true;
  }

  /// add messages
  void addMessage(types.Message message) {
    // _messages.insert(0, message);
    _currentRoom.value.messages.insert(0, message); // can't do like this
  }

  /// add a list of messages
  void addMultipleMessages(List<types.Message> messages) {
    for (var message in messages) {
      addMessage(message);
    }
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
