import 'package:get/get.dart';
import 'package:machi_app/audio/notifiers/play_button_notifier.dart';
import 'package:machi_app/datas/media.dart';

/// Display a mock button that is playing in a list of buttons.
/// UI purposes, does not do any logic. Find audio folder for logic
/// Scenario example: A screen can have a list of buttons, but there is one
/// large button at the button. That large button is the main singleton
/// the list of button is just a UI indicator
class AudioController extends GetxController {
  RxList<MediaStreamTracker> playlistButtons = <MediaStreamTracker>[].obs;

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
