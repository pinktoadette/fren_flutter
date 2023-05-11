import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:machi_app/api/machi/stream_api.dart';
import 'package:machi_app/api/machi/voice/voice_lookup.dart';
import 'package:machi_app/controller/audio_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/helpers/truncate_text.dart';
import 'package:machi_app/widgets/audio/just_play.dart';

/// allows user to change the gender of the voice
/// Note: style doesn't work in just_audio
// ignore: must_be_immutable
class StorycastVoice extends StatefulWidget {
  Storyboard story;
  StorycastVoice({Key? key, required this.story}) : super(key: key);

  @override
  _StorycastVoiceState createState() => _StorycastVoiceState();
}

class _StorycastVoiceState extends State<StorycastVoice> {
  AudioController audioController = Get.find(tag: 'audio');
  late AppLocalizations _i18n;
  final _streamApi = StreamApi();
  List<Map<String, dynamic>> _script = [];
  final bool _isPlaying = false;
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _formatData();
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  void _formatData() async {
    List<String> _trackUser = [];
    List<Map<String, dynamic>> _scriptList = [];

    for (int i = 0; i < widget.story.scene!.length; i++) {
      dynamic message = widget.story.scene![i].messages;
      if (message.type == types.MessageType.text &&
          !_trackUser.contains(message.author.firstName)) {
        _trackUser.add(message.author.firstName);
        String text = truncateText(200, message.text);
        dynamic detect = _streamApi.detectLanguage(string: text);
        List<String> lang = detect["lang"].split("-");
        List<String> voices = regionLang(lang: lang[0])
            .map((e) =>
                "${e['lang']} - ${e['region']} - ${e['age']} - ${e['person']}")
            .toList();
        _scriptList.add({
          "text": text,
          "person": message.author.firstName,
          "language": detect,
          "voices": voices,
          "selected": voices[0],
          "isPlaying": false
        });
      }
    }

    setState(() {
      _script = _scriptList;
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _i18n.translate("story_voice_assign"),
          style: Theme.of(context).textTheme.headlineMedium,
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
            child: ListView.builder(
              itemCount: _script.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _script[index]["person"],
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Text(
                      "${_i18n.translate("story_voice_read_text")}: ${_script[index]["text"]}",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                            iconSize: 0.0,
                            elevation: 16,
                            value: _script[index]["selected"],
                            underline: Container(
                              height: 1,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _script[index]["selected"] = value;
                              });
                            },
                            items: _script[index]["voices"]
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
            ))
      ],
    );
  }

  Widget _showPlay({required int index}) {
    var selection = _script[index]["selected"].split(" - ");

    String lang = "${selection[0]}-${selection[1]}";
    Map person = {"lang": lang, "person": "$lang-${selection[3]}Neural"};

    return JustPlayWidget(text: _script[index]["text"], person: person);
  }
}
