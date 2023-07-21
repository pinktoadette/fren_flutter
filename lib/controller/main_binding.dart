import 'package:flutter/material.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/controller/message_controller.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:get/get.dart';

class MainBinding implements Bindings {
  @override
  Future<void> dependencies() async {
    Get.lazyPut<BotController>(() => BotController(), tag: "bot");

    Get.lazyPut<SubscribeController>(() => SubscribeController(),
        tag: "subscribe");

    Get.lazyPut<MessageController>(() => MessageController(), tag: "message");
    Get.lazyPut<ChatController>(() => ChatController(), tag: "chatroom");
    Get.lazyPut<TimelineController>(() => TimelineController(),
        tag: "timeline");
    Get.lazyPut<StoryboardController>(() => StoryboardController(),
        tag: "storyboard");
    Get.lazyPut<CommentController>(() => CommentController(), tag: "comment");

    // Get.lazyPut<AudioController>(() => AudioController(), tag: "audio");
    debugPrint("================ Finish putting controllers ================");
  }
}
