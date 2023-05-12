// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:machi_app/api/machi/stream_api.dart';
// import 'package:machi_app/controller/audio_controller.dart';
// import 'package:machi_app/widgets/button/loading_button.dart';

// /// Just play button
// /// Used for little play widget
// class PlayControlButtons extends StatelessWidget {
//   Map<String, dynamic>? media;
//   double? size;
//   PlayControlButtons({Key? key, this.media, this.size}) : super(key: key);
//   AudioController audioController = Get.find(tag: 'audio');

//   /// sole reads read with
//   void _getBytes() async {
//     final _streamApi = StreamApi();
//     if (media != null) {
//       // BytesSource stream = await _streamApi.setStreamPlayer(media!);
//       // await audioController.audioHandler.setSingleAudioSource(stream);
//       // audioController.audioHandler.play();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<PlaybackState>(
//       stream: audioController.audioHandler.playbackState,
//       builder: (context, snapshot) {
//         final playbackState = snapshot.data;
//         final processingState = playbackState?.processingState;
//         final playing = playbackState?.playing;
//         if (processingState == AudioProcessingState.loading ||
//             processingState == AudioProcessingState.buffering) {
//           return loadingButton(size: 24);
//         } else if (playing != true) {
//           return ElevatedButton(
//               child: Icon(
//                 Iconsax.play,
//                 size: size ?? 64.0,
//                 color: Theme.of(context).colorScheme.background,
//               ),
//               onPressed: () {
//                 /// if media, then it is streaming
//                 if (media != null) {
//                   _getBytes();
//                 } else {
//                   audioController.audioHandler.play();
//                 }
//               }, //audioController.audioHandler.play,
//               style: ElevatedButton.styleFrom(
//                 shape: const CircleBorder(),
//                 padding: const EdgeInsets.all(10),
//                 foregroundColor: Theme.of(context).colorScheme.tertiary,
//               ));
//         } else {
//           return ElevatedButton(
//               child: Icon(
//                 Iconsax.pause,
//                 size: size ?? 64.0,
//                 color: Theme.of(context).colorScheme.background,
//               ),
//               onPressed: audioController.audioHandler.pause,
//               style: ElevatedButton.styleFrom(
//                 shape: const CircleBorder(),
//                 padding: const EdgeInsets.all(10),
//                 foregroundColor: Theme.of(context).colorScheme.tertiary,
//               ));
//         }
//       },
//     );
//   }
// }
