import 'package:machi_app/api/machi/stream_api.dart';
import 'package:machi_app/controller/audio_controller.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:machi_app/widgets/button/loading_button.dart';

// view story board as the creator
// ignore: must_be_immutable
class JustPlayWidget extends StatefulWidget {
  String text;
  Map person;
  double? size;
  JustPlayWidget({Key? key, required this.text, required this.person})
      : super(key: key);

  @override
  _JustPlayWidgetState createState() => _JustPlayWidgetState();
}

class _JustPlayWidgetState extends State<JustPlayWidget> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  AudioController audioController = Get.find(tag: 'audio');

  final _streamApi = StreamApi();
  final _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isBuffering = false;

  @override
  void initState() {
    ever(audioController.text, (value) => print("$value has been changed"));

    super.initState();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _getPlayer() async {
    /// person = lang-region {'lang': 'uk-UA', 'person': 'uk-UA-PolinaNeural'}
    BytesSource stream = await _streamApi.setPlayer(widget.person, widget.text);
    await _player.setAudioSource(stream);

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
          _player.dispose();
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
    return SizedBox(
      height: 45,
      width: 45,
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
              size: widget.size ?? 14,
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
      _player.pause();
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
