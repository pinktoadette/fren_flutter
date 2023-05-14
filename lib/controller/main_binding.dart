import 'package:audio_service/audio_service.dart';
import 'package:machi_app/audio/page_manager.dart';
import 'package:machi_app/audio/services/audio_handler.dart';
import 'package:machi_app/controller/audio_controller.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/controller/message_controller.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:get/get.dart';

class MainBinding implements Bindings {
  @override
  Future<void> dependencies() async {
    Get.put<BotController>(BotController(), tag: "bot");

    Get.lazyPut<UserController>(() => UserController(), tag: "user");
    Get.lazyPut<MessageController>(() => MessageController(), tag: "message");
    Get.lazyPut<ChatController>(() => ChatController(), tag: "chatroom");
    Get.lazyPut<TimelineController>(() => TimelineController(),
        tag: "timeline");
    Get.lazyPut<StoryboardController>(() => StoryboardController(),
        tag: "storyboard");

    Get.put<AudioController>(AudioController(), tag: "audio");

    await Get.putAsync<MyAudioHandler>(
        () => AudioService.init(
              builder: () => MyAudioHandler(),
              config: const AudioServiceConfig(
                androidNotificationChannelId: 'com.machi.app.audio',
                androidNotificationChannelName: 'Machi',
                androidNotificationOngoing: true,
              ),
            ),
        permanent: true,
        tag: 'audioHandler');

    // Get.put<PlaylistRepository>(DemoPlaylist(), tag: 'playlist');
    Get.put<PageManager>(PageManager(), tag: 'pageManager', permanent: true);
  }
}
