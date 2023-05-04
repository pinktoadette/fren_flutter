import 'dart:typed_data';

import 'package:fren_app/api/machi/stream.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/storyboard/bottom_sheets/publish_items.dart';
import 'package:fren_app/widgets/storyboard/story_view.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// view story board as the creator
class ViewStory extends StatefulWidget {
  bool? showName = false;
  ViewStory({Key? key, this.showName}) : super(key: key);

  @override
  _PreviewStoryState createState() => _PreviewStoryState();
}

class _PreviewStoryState extends State<ViewStory> {
  final _streamApi = StreamApi();
  final _player = AudioPlayer();
  bool _isPlaying = false;

  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  Uint8List? bytes;

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
    var streamedResponse = await _streamApi.streamAudio(token, text, 'eastus');
    Uint8List data = await streamedResponse.stream.toBytes();
    await _player.setAudioSource(BytesSource(data));

    _player.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          print("idle");
          break;
        case ProcessingState.loading:
          print("loading");
          break;
        case ProcessingState.buffering:
          print("buffering");
          break;
        case ProcessingState.ready:
          print("ready");
          break;
        case ProcessingState.completed:
          print("completed");
          _player.pause();
          setState(() {
            _isPlaying = false;
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          storyboardController.currentStory.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: BackButton(
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          InkWell(
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(Iconsax.menu),
              ),
              onTap: () {
                _publish();
              })
        ],
      ),
      body: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Stack(children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  StoryViewDetails(
                    story: storyboardController.currentStory,
                  ),
                ])
          ])),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _listen();
        },
        backgroundColor: APP_ACCENT_COLOR,
        child: Icon(_isPlaying == true ? Iconsax.pause : Iconsax.play,
            color: Theme.of(context).colorScheme.background),
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

  void _publish() async {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        builder: (context) => PublishItemsWidget(
            story: storyboardController.currentStory,
            onCaptureImage: (isCapture) async {
              // if (isCapture == true) {
              //   Uint8List? bytes = await controller.capture();
              //   _accessStorage(bytes!);
              // }
            }));
  }
}
