import 'dart:typed_data';

import 'package:machi_app/api/machi/stream_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/widgets/button/loading_button.dart';

// view story board as the creator
// ignore: must_be_immutable
class MiniAudioWidget extends StatefulWidget {
  Storyboard post;
  MiniAudioWidget({Key? key, required this.post}) : super(key: key);

  @override
  _MiniAudioWidgetState createState() => _MiniAudioWidgetState();
}

class _MiniAudioWidgetState extends State<MiniAudioWidget> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  final _streamApi = StreamApi();
  final _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _getPlayer() async {
    String token = await _streamApi.getAuthToken();
    String text = "test world";
    // storyboardController.currentStory.story!.map((s) {
    //   dynamic message = s.messages;
    //   if (s.messages.type == types.MessageType.text) {
    //     return message.text;
    //   }
    // }).join(" ");
    http.StreamedResponse streamedResponse =
        await _streamApi.streamAudio(token, text, 'eastus');
    Uint8List data = await streamedResponse.stream.toBytes();
    await _player.setAudioSource(BytesSource(data));

    if (storyboardController.currentStory.storyboardId !=
        widget.post.storyboardId) {
      _player.pause();
    }

    _player.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          break;
        case ProcessingState.loading:
          setState(() {
            _isBuffering = true;
          });
          break;
        case ProcessingState.buffering:
          setState(() {
            _isBuffering = true;
          });
          break;
        case ProcessingState.ready:
          setState(() {
            _isBuffering = false;
          });
          break;
        case ProcessingState.completed:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PLAY_BUTTON_WIDTH,
      width: PLAY_BUTTON_WIDTH,
      child: _playButton(),
    );
  }

  Widget _playButton() {
    return ElevatedButton(
      onPressed: () {
        _listen();
      },
      child: _isBuffering
          ? loadingButton(size: 24)
          : Icon(
              _isPlaying == true ? Iconsax.pause : Iconsax.play,
              color: Theme.of(context).colorScheme.background,
              size: 14,
            ),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(10),
        foregroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  void _listen() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_player.audioSource == null) {
        _getPlayer();
      }
      _player.play();
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }
}
