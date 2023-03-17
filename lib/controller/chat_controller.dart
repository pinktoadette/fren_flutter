
import 'package:flutter/foundation.dart';
import 'package:fren_app/api/machi/message_api.dart';
import 'package:fren_app/controller/user_controller.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatController extends GetxController implements GetxService {
  final BotController botController = Get.find();// current bot
  final UserController userController = Get.find(); // current user
  late Rx<types.User> _chatUser;
  late Rx<types.User> _chatBot;
  late Rx<types.Room> _room;
  RxList<types.Message> _messages = <types.Message>[].obs;

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

  types.Room get room => _room.value;
  set room(types.Room value) => _room.value = value;

  Stream<List<types.Message>> get streamList async* {
    yield _messages;
  }
  Stream<types.Room> get streamRoom async* {
    yield room;
  }


  @override
  void onInit() async {
    _chatUser = types.User(
      id: userController.user.userId,
      firstName: userController.user.userFullname,
    ).obs;

    _room = types.Room(
        id: "",
        createdAt: 0,
        users: [chatUser],
        type: types.RoomType.group
    ).obs;

    super.onInit();
  }

  /// create new chatroom with botId
  /// can invite users. So type is a group
  void onCreateRoom(room) {
    _room = types.Room(
      id: room["roomId"],
      createdAt: room["createdAt"],
      users: [chatUser],
      type: types.RoomType.group
    ).obs;
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
    _messages.insert(0, message);
  }

  /// add a list of messages
  void addMultipleMessages(List<types.Message> messages) {
    for (var message in messages) {
      addMessage(message);
    }
  }

  Future<void> _fetchLocalMessages() async {
    List<types.Message> localMessage = await _messagesApi.getLocalDbMessages();
    List<types.Message> lastRemoteMessage = await _messagesApi.getMessages(0, 1);

    if (localMessage.isNotEmpty) {
      int localTimestamp = localMessage[0].createdAt?.toInt() ?? 0;
      if (lastRemoteMessage[0].createdAt! <= localTimestamp ) {
        debugPrint("Using db -> local. Message length ${localMessage.length}");
        addMultipleMessages(localMessage);
        return;
      }
    }
    _fetchRemoteUserMessages();
  }

  Future<void> _fetchRemoteUserMessages() async {
    List<types.Message> messages = await _messagesApi.getMessages(0, 50);
    debugPrint("Using db -> remote. Message length ${messages.length}");
    addMultipleMessages(messages);
  }



}
