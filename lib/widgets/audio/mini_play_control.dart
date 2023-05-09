import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:machi_app/api/machi/stream.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;
import 'package:machi_app/widgets/timeline/timeline_header.dart';

// view story board as the creator
class MiniAudioWidget extends StatefulWidget {
  StoryUser user;
  MiniAudioWidget({Key? key, required this.user}) : super(key: key);

  @override
  _MiniAudioWidgetState createState() => _MiniAudioWidgetState();
}

class _MiniAudioWidgetState extends State<MiniAudioWidget> {
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
        height: 60,
        padding: const EdgeInsets.only(left: 10, right: 10),
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
            borderRadius: const BorderRadius.all(Radius.circular(50))),
        child: Stack(alignment: Alignment.center, children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TimelineHeader(
                      showAvatar: true, showName: true, user: widget.user),
                  SizedBox(
                    height: 45,
                    width: 45,
                    child: _playButton(),
                  )
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Center(
                child: SizedBox(
                    width: width * 0.8,
                    child: StreamBuilder(
                        stream: _player.positionStream,
                        builder: (context, asyncSnapshot) {
                          double? value;
                          if (_player.audioSource == null &&
                              _isBuffering == false) {
                            value = 0;
                          } else if (_isBuffering == true) {
                            value = null;
                          } else {
                            value = _player.position.inSeconds /
                                _player.duration!.inSeconds;
                          }
                          return SizedBox(
                            height: 2,
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                              child: LinearProgressIndicator(
                                value: value,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    APP_ACCENT_COLOR),
                                backgroundColor: const Color(0xffD6D6D6),
                              ),
                            ),
                          );
                        }))),
          )
        ]));
  }

  Widget _playButton() {
    return ElevatedButton(
      onPressed: () {
        _listen();
      },
      child: Icon(
        _isPlaying == true ? Iconsax.pause : Iconsax.play,
        color: Theme.of(context).colorScheme.background,
        size: 14,
      ),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(10),
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
