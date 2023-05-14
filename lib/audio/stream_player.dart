import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/audio/notifiers/play_button_notifier.dart';
import 'package:machi_app/audio/page_manager.dart';
import 'package:machi_app/controller/audio_controller.dart';
import 'package:machi_app/datas/media.dart';

/// This play button should be global button
/// each individual widget, play button should have a
/// an obs to their id to indicate if played. This is just a visual change
class StreamPlaylistButton extends StatelessWidget {
  double? size;
  int index;
  final Function(dynamic data)? onPress;
  StreamPlaylistButton({Key? key, required this.index, this.size, this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(child: _returnButton());
    // return ValueListenableBuilder<MediaStreamTracker>(
    //   valueListenable: audiocontroller.playlistButtons[index],
    //   builder: (_, value, __) {
    //     ButtonState state = value.state;
    //     switch (state) {
    //       case ButtonState.loading:
    //         return Container(
    //           margin: const EdgeInsets.all(8.0),
    //           width: size ?? 32.0,
    //           height: size ?? 32.0,
    //           child: const CircularProgressIndicator(),
    //         );
    //       case ButtonState.paused:
    //         return IconButton(
    //           icon: const Icon(Icons.play_arrow),
    //           iconSize: size ?? 32.0,
    //           onPressed: () {
    //             onPress!({"play": true});
    //             pageManager.play;
    //           },
    //         );
    //       case ButtonState.playing:
    //         return IconButton(
    //           icon: const Icon(Icons.pause),
    //           iconSize: size ?? 32.0,
    //           onPressed: pageManager.pause,
    //         );
    //     }
    //   },
    // );
  }

  Widget _returnButton() {
    final audiocontroller = Get.find<AudioController>(tag: 'audio');
    final pageManager = Get.find<PageManager>(tag: 'pageManager');

    MediaStreamTracker media = audiocontroller.playlistButtons[index];
    switch (media.state) {
      case ButtonState.loading:
        return Container(
          margin: const EdgeInsets.all(8.0),
          width: size ?? 32.0,
          height: size ?? 32.0,
          child: const CircularProgressIndicator(),
        );
      case ButtonState.paused:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          iconSize: size ?? 32.0,
          onPressed: () {
            onPress!({"play": true});
            pageManager.play;
          },
        );
      case ButtonState.playing:
        return IconButton(
          icon: const Icon(Icons.pause),
          iconSize: size ?? 32.0,
          onPressed: pageManager.pause,
        );
    }
  }
}
