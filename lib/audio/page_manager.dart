import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/stream_api.dart';
import 'package:machi_app/audio/services/audio_handler.dart';
import 'package:machi_app/datas/media.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'package:audio_service/audio_service.dart';
import 'package:http/http.dart' as http;

class PageManager {
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  late MyAudioHandler audioHandler;

  // Events: Calls coming from the UI

  void init() async {
    audioHandler = Get.find(tag: 'audioHandler');

    // await _loadPlaylist();
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  // Future<void> _loadPlaylist() async {
  //   final songRepository = Get.find(tag: 'playlist');
  //   final playlist = await songRepository.fetchInitialPlaylist();
  //   final mediaItems = playlist
  //       .map((song) => MediaItem(
  //             id: song['id'] ?? '',
  //             album: song['album'] ?? '',
  //             title: song['title'] ?? '',
  //             extras: {'url': song['url']},
  //           ))
  //       .toList();
  //   audioHandler.addQueueItems(mediaItems);
  // }

  void addStream(MediaStreamItem media) async {
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');

    final streamApi = StreamApi();
    String token = await streamApi.getAuthToken();
    http.StreamedResponse streamedResponse = await streamApi.streamPlayer(
        key: token, region: 'eastus', media: media);
    Uint8List data = await streamedResponse.stream.toBytes();
    audioHandler.customAction("source", {"byteSource": BytesSource(data)});
  }

  void _listenToChangesInPlaylist() {
    audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = '';
      } else {
        final newList = playlist.map((item) => item.title).toList();
        playlistNotifier.value = newList;
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        audioHandler.seek(Duration.zero);
        audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final mediaItem = audioHandler.mediaItem.value;
    final playlist = audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  void play() => audioHandler.play();
  void pause() => audioHandler.pause();

  void seek(Duration position) => audioHandler.seek(position);

  void previous() => audioHandler.skipToPrevious();
  void next() => audioHandler.skipToNext();

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  // Future<void> add() async {
  //   final songRepository = Get.find(tag: 'playlist');
  //   final song = await songRepository.fetchAnotherSong();
  //   final mediaItem = MediaItem(
  //     id: song['id'] ?? '',
  //     album: song['album'] ?? '',
  //     title: song['title'] ?? '',
  //     extras: {'url': song['url']},
  //   );
  //   audioHandler.addQueueItem(mediaItem);
  // }

  void remove() {
    final lastIndex = audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    audioHandler.removeQueueItemAt(lastIndex);
  }

  void dispose() {
    audioHandler.customAction('dispose');
  }

  void stop() {
    audioHandler.stop();
  }
}
