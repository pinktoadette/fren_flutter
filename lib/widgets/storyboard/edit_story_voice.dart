import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/stream_api.dart';
import 'package:machi_app/api/machi/voice/voice_lookup.dart';
import 'package:machi_app/audio/notifiers/play_button_notifier.dart';
import 'package:machi_app/audio/page_manager.dart';
import 'package:machi_app/audio/stream_player.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/audio_controller.dart';
import 'package:machi_app/datas/media.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/helpers/truncate_text.dart';
import 'package:uuid/uuid.dart';

/// allows user to change the gender of the voice
class StorycastVoice extends StatefulWidget {
  Storyboard story;
  StorycastVoice({Key? key, required this.story}) : super(key: key);

  @override
  _StorycastVoiceState createState() => _StorycastVoiceState();
}

class _StorycastVoiceState extends State<StorycastVoice> {
  late AppLocalizations _i18n;
  AudioController audioController = Get.find(tag: 'audio');
  final _streamApi = StreamApi();

  @override
  void initState() {
    super.initState();
    _formatData();
  }

  @override
  void dispose() {
    audioController.playlistButtons.clear();
    super.dispose();
  }

  void _formatData() async {
    List<String> _trackUser = [];
    for (int i = 0; i < widget.story.scene!.length; i++) {
      dynamic message = widget.story.scene![i].messages;
      if (message.type == types.MessageType.text &&
          !_trackUser.contains(message.author.firstName)) {
        _trackUser.add(message.author.firstName);
        String text = truncateText(200, message.text);
        Map<String, String> language = _streamApi.detectLanguage(string: text);
        List<String> voices = regionLang(lang: language["lang"]!)
            .map((e) =>
                "${e['lang']} - ${e['region']} - ${e['age']} - ${e['person']}")
            .toList();
        audioController.playlistButtons.add(
          MediaStreamTracker(
              item: MediaStreamItem(
                id: const Uuid().v1(),
                character: MediaStreamCharacter(
                    id: message.author.id,
                    username: message.author.firstName,
                    text: text,
                    language: TTSLanguage(
                        language: language["lang"]!,
                        region: language["region"]!),
                    voiceName: voices[0]),
              ),
              state: ButtonState.paused,
              voiceList: voices,
              voiceSelection: voices[0]),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _i18n.translate("story_voice_assign"),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  _i18n.translate("SAVE"),
                  style: const TextStyle(fontSize: 14),
                ))
          ],
        ),
        Text(
          _i18n.translate("story_voice_assign_info"),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
            height: height * 0.7,
            child: Obx(() => ListView.builder(
                  itemCount: audioController.playlistButtons.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          audioController
                              .playlistButtons[index].item.character!.username,
                          style: const TextStyle(
                              fontSize: 16,
                              color: APP_ACCENT_COLOR,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${_i18n.translate("story_voice_read_text")}: ${audioController.playlistButtons[index].item.character!.text}",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButton<String>(
                                iconSize: 0.0,
                                elevation: 16,
                                value: audioController
                                    .playlistButtons[index].voiceSelection,
                                underline: Container(
                                  height: 1,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    audioController.playlistButtons[index] =
                                        audioController.playlistButtons[index]
                                            .copyWith(voiceSelection: value);
                                  });
                                },
                                items: audioController
                                    .playlistButtons[index].voiceList
                                    .map<DropdownMenuItem<String>>((value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList()),
                            _showPlay(index: index)
                          ],
                        ),
                        const Divider(
                          height: 10,
                        ),
                      ],
                    );
                  },
                )))
      ],
    );
  }

  Widget _showPlay({required int index}) {
    return StreamPlaylistButton(
        size: 14,
        index: index,
        onPress: (val) async {
          await _setupVoice(index: index);
        });
  }

  Future<void> _setupVoice({required int index}) async {
    final pageManager = Get.find<PageManager>(tag: 'pageManager');

    var selection =
        audioController.playlistButtons[index].voiceSelection.split(" - ");
    String lang = "${selection[0]}-${selection[1]}";

    MediaStreamItem item = MediaStreamItem(
      id: const Uuid().v4(),
      character: MediaStreamCharacter(
          id: audioController.playlistButtons[index].item.character!.id,
          username:
              audioController.playlistButtons[index].item.character!.username,
          text: audioController.playlistButtons[index].item.character!.text,
          language: TTSLanguage(language: selection[0], region: selection[1]),
          voiceName: "$lang-${selection[3]}Neural"),
    );
    pageManager.addStream(item);
  }
}
