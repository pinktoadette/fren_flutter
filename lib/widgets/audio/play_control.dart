import 'dart:math';
import 'dart:typed_data';

import 'package:fren_app/api/machi/stream.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;

// view story board as the creator
class AudioWidget extends StatefulWidget {
  AudioWidget({Key? key}) : super(key: key);

  @override
  _AudioWidgetState createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  final _streamApi = StreamApi();
  final _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isBuffering = false;
  late AppLocalizations _i18n;

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
    String text = storyboardController.currentStory.scene!.map((s) {
      dynamic message = s.messages;
      if (s.messages.type == types.MessageType.text) {
        return message.text;
      }
    }).join(" ");
    http.StreamedResponse streamedResponse =
        await _streamApi.streamAudio(token, text, 'eastus');
    Uint8List data = await streamedResponse.stream.toBytes();
    await _player.setAudioSource(BytesSource(data));

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
          break;
        case ProcessingState.completed:
          _player.pause();
          setState(() {
            _isPlaying = false;
            _isBuffering = false;
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    return Container(
        height: 150,
        width: width,
        padding: const EdgeInsets.all(20),
        child: Card(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _playBackward(),
                const SizedBox(width: 25),
                _playButton(),
                const SizedBox(width: 25),
                _playForward(),
              ],
            ),
            StreamBuilder(
                stream: _player.positionStream,
                builder: (context, asyncSnapshot) {
                  double? value;
                  if (_player.audioSource == null && _isBuffering == false) {
                    value = 0;
                  } else if (_isBuffering == true) {
                    value = null;
                  } else {
                    value = _player.position.inSeconds /
                        _player.duration!.inSeconds;
                  }
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: width * 0.8,
                    height: 10,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      child: LinearProgressIndicator(
                        value: value,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            APP_ACCENT_COLOR),
                        backgroundColor: const Color(0xffD6D6D6),
                      ),
                    ),
                  );
                })
          ],
        )));
  }

  Widget _playBackward() {
    return IconButton(
      onPressed: () async {
        await _player
            .seek(Duration(seconds: min(0, _player.position.inSeconds - 10)));
        setState(() {
          _isBuffering = false;
        });
      },
      icon: Icon(Iconsax.backward_10_seconds,
          color: Theme.of(context).colorScheme.primary),
    );
  }

  Widget _playForward() {
    return IconButton(
      onPressed: () async {
        await _player.seek(Duration(seconds: _player.position.inSeconds + 10));
        setState(() {
          _isBuffering = false;
        });
      },
      icon: Icon(Iconsax.forward_10_seconds,
          color: Theme.of(context).colorScheme.primary),
    );
  }

  Widget _playButton() {
    return ElevatedButton(
      onPressed: () {
        _listen();
      },
      child: Icon(_isPlaying == true ? Iconsax.pause : Iconsax.play,
          color: Theme.of(context).colorScheme.background),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        foregroundColor:
            Theme.of(context).colorScheme.tertiary, // <-- Splash color
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
