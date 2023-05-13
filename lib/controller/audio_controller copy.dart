import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:machi_app/api/machi/stream_api.dart';
import 'package:machi_app/datas/media.dart';

/// Tracks current audio that is playing
/// Note: Cannot set the just_audio in controller, can only do in the widget
class AudioController extends GetxController {
  final _player = AudioPlayer();

  late AudioHandler audioHandler;
  // Stream via Bytes
  Rx<MediaStreamItem>? currentStream;
  List<BytesSource> listStream = [];
  Rx<BytesSource>? currentBytes;


  void playStreamList(int index) async {
    await _player.setAudioSource(listStream[index]);
    await _player.play();
  }

  Future<BytesSource> createCurrentStrem(MediaStreamItem item) async {
    BytesSource track = await _createAudioSource(item);
    currentBytes = track.obs;
    return track;
  }

  Future<void> addQueueItems(MediaStreamItem item) async {
    BytesSource track = await _createAudioSource(item);
    listStream.add(track);
  }

  Future<BytesSource> _createAudioSource(MediaStreamItem item) async {
    final _streamApi = StreamApi();

    BytesSource stream = await _streamApi.getCurrentStreamBytes(item);
    return stream;
  }

  Future<void> onPlay() => _player.play();

  Future<void> onPause() => _player.pause();

  Future<void> onSeekTo(Duration position) => _player.seek(position);

  void onDispose() => _player.dispose();
}
