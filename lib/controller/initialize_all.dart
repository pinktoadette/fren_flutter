import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/controller/message_controller.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/controller/timeline_controller.dart';
import 'package:fren_app/controller/user_controller.dart';
import 'package:get/get.dart';

void initializeAllControllers() {
  // Get.lazyPut(() => BotController());
  Get.put<BotController>(BotController(), tag: "bot");
  Get.lazyPut<UserController>(() => UserController(), tag: "user");
  Get.lazyPut<MessageController>(() => MessageController(), tag: "message");
  Get.lazyPut<ChatController>(() => ChatController(), tag: "chatroom");
  Get.lazyPut<TimelineController>(() => TimelineController(), tag: "timeline");
  Get.lazyPut<StoryboardController>(() => StoryboardController(),
      tag: "storyboard");
}
