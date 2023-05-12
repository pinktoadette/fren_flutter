// import 'package:audio_service/audio_service.dart';
// import 'package:get/get.dart';
// import 'package:machi_app/audio/common.dart';
// import 'package:machi_app/audio/controls/control_buttons.dart';
// import 'package:machi_app/audio/queue_state.dart';
// import 'package:machi_app/controller/audio_controller.dart';
// import 'package:flutter/material.dart';

// // Common audio player
// class AudioPlayWidget extends StatelessWidget {
//   AudioController audioController = Get.find(tag: 'audio');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // MediaItem display
//             Expanded(
//               child: StreamBuilder<MediaItem?>(
//                 stream: audioController.audioHandler.mediaItem,
//                 builder: (context, snapshot) {
//                   final mediaItem = snapshot.data;
//                   if (mediaItem == null) return const SizedBox();
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       if (mediaItem.artUri != null)
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Center(
//                               child: Image.network('${mediaItem.artUri!}'),
//                             ),
//                           ),
//                         ),
//                       Text(mediaItem.album ?? '',
//                           style: Theme.of(context).textTheme.headline6),
//                       Text(mediaItem.title),
//                     ],
//                   );
//                 },
//               ),
//             ),
//             // Playback controls
//             ControlButtons(audioController.audioHandler),
//             // A seek bar.
//             StreamBuilder<PositionData>(
//               stream: audioController.positionDataStream,
//               builder: (context, snapshot) {
//                 final positionData = snapshot.data ??
//                     PositionData(Duration.zero, Duration.zero, Duration.zero);
//                 return SeekBar(
//                   duration: positionData.duration,
//                   position: positionData.position,
//                   onChangeEnd: (newPosition) {
//                     audioController.audioHandler.seek(newPosition);
//                   },
//                 );
//               },
//             ),
//             const SizedBox(height: 8.0),
//             // Repeat/shuffle controls
//             Row(
//               children: [
//                 StreamBuilder<AudioServiceRepeatMode>(
//                   stream: audioController.audioHandler.playbackState
//                       .map((state) => state.repeatMode)
//                       .distinct(),
//                   builder: (context, snapshot) {
//                     final repeatMode =
//                         snapshot.data ?? AudioServiceRepeatMode.none;
//                     const icons = [
//                       Icon(Icons.repeat, color: Colors.grey),
//                       Icon(Icons.repeat, color: Colors.orange),
//                       Icon(Icons.repeat_one, color: Colors.orange),
//                     ];
//                     const cycleModes = [
//                       AudioServiceRepeatMode.none,
//                       AudioServiceRepeatMode.all,
//                       AudioServiceRepeatMode.one,
//                     ];
//                     final index = cycleModes.indexOf(repeatMode);
//                     return IconButton(
//                       icon: icons[index],
//                       onPressed: () {
//                         audioController.audioHandler.setRepeatMode(cycleModes[
//                             (cycleModes.indexOf(repeatMode) + 1) %
//                                 cycleModes.length]);
//                       },
//                     );
//                   },
//                 ),
//                 StreamBuilder<bool>(
//                   stream: audioController.audioHandler.playbackState
//                       .map((state) =>
//                           state.shuffleMode == AudioServiceShuffleMode.all)
//                       .distinct(),
//                   builder: (context, snapshot) {
//                     final shuffleModeEnabled = snapshot.data ?? false;
//                     return IconButton(
//                       icon: shuffleModeEnabled
//                           ? const Icon(Icons.shuffle, color: Colors.orange)
//                           : const Icon(Icons.shuffle, color: Colors.grey),
//                       onPressed: () async {
//                         final enable = !shuffleModeEnabled;
//                         await audioController.audioHandler.setShuffleMode(enable
//                             ? AudioServiceShuffleMode.all
//                             : AudioServiceShuffleMode.none);
//                       },
//                     );
//                   },
//                 ),
//               ],
//             ),
//             // Playlist
//             SizedBox(
//               height: 240.0,
//               child: StreamBuilder<QueueState>(
//                 stream: audioController.audioHandler.queueState,
//                 builder: (context, snapshot) {
//                   final queueState = snapshot.data ?? QueueState.empty;
//                   final queue = queueState.queue;
//                   return ReorderableListView(
//                     onReorder: (int oldIndex, int newIndex) {
//                       if (oldIndex < newIndex) newIndex--;
//                       audioController.audioHandler
//                           .moveQueueItem(oldIndex, newIndex);
//                     },
//                     children: [
//                       for (var i = 0; i < queue.length; i++)
//                         Dismissible(
//                           key: ValueKey(queue[i].id),
//                           background: Container(
//                             color: Colors.redAccent,
//                             alignment: Alignment.centerRight,
//                             child: const Padding(
//                               padding: EdgeInsets.only(right: 8.0),
//                               child: Icon(Icons.delete, color: Colors.white),
//                             ),
//                           ),
//                           onDismissed: (dismissDirection) {
//                             audioController.audioHandler.removeQueueItemAt(i);
//                           },
//                           child: Material(
//                             color: i == queueState.queueIndex
//                                 ? Colors.grey.shade300
//                                 : null,
//                             child: ListTile(
//                               title: Text(queue[i].title),
//                               onTap: () => audioController.audioHandler
//                                   .skipToQueueItem(i),
//                             ),
//                           ),
//                         ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
