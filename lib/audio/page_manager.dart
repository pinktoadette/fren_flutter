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

  // Events: Calls coming from the UI

  void init() async {
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
    audioHandler.customAction(
        "source", {"byteSource": BytesSource(data), "id": media.id});
  }

  void _listenToChangesInPlaylist() {
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');

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
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');

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
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');

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
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');

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
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');

    audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');

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

  void play() {
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');
    audioHandler.play();
  }

  void pause() {
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');
    audioHandler.pause();
  }

  void seek(Duration position) {
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');
    audioHandler.seek(position);
  }

  void previous() {
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');
    audioHandler.skipToPrevious();
  }

  void next() {
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');
    audioHandler.skipToNext();
  }

  void repeat() {
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');

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
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');

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
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');

    final lastIndex = audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    audioHandler.removeQueueItemAt(lastIndex);
  }

  void dispose() {
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');
    audioHandler.customAction('dispose');
  }

  void stop() {
    AudioHandler audioHandler = Get.find<MyAudioHandler>(tag: 'audioHandler');
    audioHandler.stop();
  }
}
