// import 'package:audio_service/audio_service.dart';
// import 'package:machi_app/controller/audio_controller.dart';
// import 'package:machi_app/controller/storyboard_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:machi_app/widgets/button/loading_button.dart';

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
//     return _playButton();
//     //   return StreamBuilder(
//     //     stream: audioController.player.playerStateStream,
//     //     builder: (context, snapshot) {
//     //       final playbackState = snapshot.data;
//     //       final processingState = playbackState?.processingState;
//     //       final playing = playbackState?.playing;
//     //       if (processingState == AudioProcessingState.loading ||
//     //           processingState == AudioProcessingState.buffering) {
//     //         return loadingButton(size: 24);
//     //       } else if (playing != true ||
//     //           processingState == AudioProcessingState.idle) {
//     //         return _playButton();
//     //       } else {
//     //         return ElevatedButton(
//     //             child: Icon(
//     //               Iconsax.pause,
//     //               size: widget.size ?? 64.0,
//     //               color: Theme.of(context).colorScheme.background,
//     //             ),
//     //             onPressed: () {
//     //               widget.onPress({"play": false});
//     //             },
//     //             style: ElevatedButton.styleFrom(
//     //               shape: const CircleBorder(),
//     //               padding: const EdgeInsets.all(10),
//     //               foregroundColor: Theme.of(context).colorScheme.tertiary,
//     //             ));
//     //       }
//     //     },
//     //   );
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
//   //   BytesSource stream = await _streamApi.getCurrentStreamBytes();
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
//   //       widget.onPress(true);
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
// }
