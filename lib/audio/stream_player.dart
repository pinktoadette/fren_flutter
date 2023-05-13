import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/audio/notifiers/play_button_notifier.dart';
import 'package:machi_app/audio/page_manager.dart';

class PlayButton extends StatelessWidget {
  double? size;
  final Function(dynamic data)? onPress;
  PlayButton({Key? key, this.size, this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = Get.find<PageManager>(tag: 'pageManager');

    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
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
      },
    );
  }
}





// // ignore: must_be_immutable
// class StreamPlayWidget extends StatefulWidget {
//   double? size;
//   String id;
//   final Function(dynamic data) onPress;

//   StreamPlayWidget(
//       {Key? key, required this.onPress, required this.size, required this.id})
//       : super(key: key);

//   @override
//   _JustPlayWidgetState createState() => _JustPlayWidgetState();
// }

// class _JustPlayWidgetState extends State<StreamPlayWidget> {
//   StoryboardController storyboardController = Get.find(tag: 'storyboard');
//   AudioController audioController = Get.find(tag: 'audio');
//   final _player = AudioPlayer();
//   bool _isPlaying = false;
//   bool _isBuffering = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     audioController.onDispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: audioController.player.playerStateStream,
//       builder: (context, snapshot) {
//         final playbackState = snapshot.data;
//         final processingState = playbackState?.processingState;
//         final playing = playbackState?.playing;
//         if (processingState == AudioProcessingState.loading ||
//             processingState == AudioProcessingState.buffering) {
//           return loadingButton(size: 24);
//         } else if (playing != true ||
//             processingState == AudioProcessingState.idle) {
//           return _playButton();
//         } else {
//           return ElevatedButton(
//               child: Icon(
//                 Iconsax.pause,
//                 size: widget.size ?? 64.0,
//                 color: Theme.of(context).colorScheme.background,
//               ),
//               onPressed: () {
//                 widget.onPress({"play": false});
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: const CircleBorder(),
//                 padding: const EdgeInsets.all(10),
//                 foregroundColor: Theme.of(context).colorScheme.tertiary,
//               ));
//         }
//       },
//     );
//   }

//   Widget _playButton() {
//     return ElevatedButton(
//         child: Icon(
//           Iconsax.play,
//           size: widget.size ?? 64.0,
//           color: Theme.of(context).colorScheme.background,
//         ),
//         onPressed: () {
//           widget.onPress({"play": true});
//         }, //audioController.audioHandler.play,
//         style: ElevatedButton.styleFrom(
//           shape: const CircleBorder(),
//           padding: const EdgeInsets.all(10),
//           foregroundColor: Theme.of(context).colorScheme.tertiary,
//         ));
//   }

//   // void _getPlayer() async {
//   //   /// person = lang-region {'lang': 'uk-UA', 'person': 'uk-UA-PolinaNeural'}
//   //   BytesSource stream = audioController.currentBytes!.value;
//   //   await _player.setAudioSource(stream);

//   //   _player.playerStateStream.listen((state) {
//   //     switch (state.processingState) {
//   //       case ProcessingState.idle:
//   //         break;
//   //       case ProcessingState.loading:
//   //         setState(() {
//   //           _isBuffering = true;
//   //         });
//   //         break;
//   //       case ProcessingState.buffering:
//   //         setState(() {
//   //           _isBuffering = true;
//   //         });
//   //         break;
//   //       case ProcessingState.ready:
//   //         setState(() {
//   //           _isBuffering = false;
//   //         });
//   //         break;
//   //       case ProcessingState.completed:
//   //         setState(() {
//   //           _isPlaying = false;
//   //           _isBuffering = false;
//   //         });
//   //         _player.seek(Duration.zero);
//   //         _player.pause();
//   //         break;
//   //     }
//   //   });
//   // }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return SizedBox(
//   //     height: 45,
//   //     width: 45,
//   //     child: _playButton(),
//   //   );
//   // }

//   // Widget _playButton() {
//   //   return ElevatedButton(
//   //     onPressed: () {
//   //       widget.onPress({"play": true});
//   //       _listen();
//   //     },
//   //     child: _isBuffering
//   //         ? loadingButton(size: 24)
//   //         : Icon(
//   //             _isPlaying == true ? Iconsax.pause : Iconsax.play,
//   //             color: Theme.of(context).colorScheme.background,
//   //             size: widget.size ?? 14,
//   //           ),
//   //     style: ElevatedButton.styleFrom(
//   //       shape: const CircleBorder(),
//   //       padding: const EdgeInsets.all(10),
//   //       foregroundColor: Theme.of(context).colorScheme.tertiary,
//   //     ),
//   //   );
//   // }

//   // void _listen() async {
//   //   if (_player.playing == true) {
//   //     _player.pause();
//   //   } else {
//   //     _getPlayer();
//   //     await _player.play();
//   //   }

//   //   setState(() {
//   //     _isPlaying = !_isPlaying;
//   //   });
//   // }


// }
