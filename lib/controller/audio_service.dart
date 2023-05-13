import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:machi_app/audio/services/audio_handler.dart';

/// Tracks current audio that is playing
/// audio_service doesn't work with getx
/// https://github.com/ryanheise/audio_service/issues/935
class AudioGetService extends GetxService {
  @override
  void onInit() async {
    super.onInit();
    await Get.putAsync<MyAudioHandler>(
        () => AudioService.init(
              builder: () => MyAudioHandler(),
              config: const AudioServiceConfig(
                androidNotificationChannelId: 'com.machi.app.audio',
                androidNotificationChannelName: 'Machi',
                androidNotificationOngoing: true,
                androidStopForegroundOnPause: true,
              ),
            ),
        permanent: true,
        tag: 'audioHandler');
  }
}
