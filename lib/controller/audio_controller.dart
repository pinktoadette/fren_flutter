import 'package:get/get.dart';
import 'package:machi_app/audio/notifiers/play_button_notifier.dart';
import 'package:machi_app/datas/media.dart';
import 'package:audio_service/audio_service.dart';
import 'package:machi_app/audio/page_manager.dart';
import 'package:machi_app/audio/services/audio_handler.dart';

/// Display a mock button that is playing in a list of buttons.
/// UI purposes, does not do any logic. Find audio folder for logic
/// Scenario example: A screen can have a list of buttons, but there is one
/// large button at the button. That large button is the main singleton
/// the list of button is just a UI indicator
class AudioController extends GetxController {
  RxList<MediaStreamTracker> playlistButtons = <MediaStreamTracker>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await Get.putAsync<MyAudioHandler>(
        () => AudioService.init(
              builder: () => MyAudioHandler(),
              config: const AudioServiceConfig(
                androidNotificationChannelId: 'com.machi.app.audio',
                androidNotificationChannelName: 'Machi',
              ),
            ),
        permanent: true,
        tag: 'audioHandler');

    // Get.put<PlaylistRepository>(DemoPlaylist(), tag: 'playlist');
    Get.put<PageManager>(PageManager(), tag: 'pageManager', permanent: true);
  }

  void addTrackStream(
      {required MediaStreamItem media,
      required ButtonState state,
      required String voiceSelection,
      required List<String> voiceList}) {
    playlistButtons.add(MediaStreamTracker(
        state: state,
        item: media,
        voiceList: voiceList,
        voiceSelection: voiceSelection));
    update();
  }
}
