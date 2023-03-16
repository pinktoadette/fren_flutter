
import 'package:fren_app/controller/user_controller.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatController extends GetxController {
  final BotController botController = Get.find();// current bot
  final UserController userController = Get.find(); // current user
  late Rx<types.User> _chatUser;
  late Rx<types.User> _chatBot;
  RxList<types.Message> _messages = <types.Message>[].obs;

  String? error;
  bool retrieveAPI = true;
  bool isLoading = false;
  bool isInitial = false;
  bool isTest = false;

  types.User get chatUser => _chatUser.value;
  set chatUser(types.User value) => _chatUser.value = value;

  types.User get chatBot => _chatBot.value;
  set chatBot(types.User value) => _chatBot.value = value;

  // List<types.Message> get messages => _messages;
  // set messages(List<types.Message> value) => _messages.value = value;

  Stream<List<types.Message>> get streamList async* {
    yield _messages;
  }

  @override
  void onInit() async {
    _chatUser = types.User(
      id: userController.user.userId,
      firstName: userController.user.userFullname,
    ).obs;

    onChatLoad();
    super.onInit();
  }

  /// load the current bot
  void onChatLoad() {
    _chatBot = types.User(
      id: botController.bot.botId,
      firstName: botController.bot.name,
    ).obs;

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


}
