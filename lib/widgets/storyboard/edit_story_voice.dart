import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/stream_api.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

/// allows user to change the gender of the voice
///
/// Note: style doesn't work in just_audio
class StorycastVoice extends StatefulWidget {
  Storyboard story;
  StorycastVoice({Key? key, required this.story}) : super(key: key);

  @override
  _StorycastVoiceState createState() => _StorycastVoiceState();
}

class _StorycastVoiceState extends State<StorycastVoice> {
  late AppLocalizations _i18n;
  final _streamApi = StreamApi();
  List<String> roles = [];

  @override
  void initState() {
    _formatData();
    super.initState();
  }

  void _formatData() async {
    List<String> _trackUser = [];
    List<dynamic> _script = [];

    for (int i = 0; i < widget.story.scene!.length; i++) {
      dynamic message = widget.story.scene![i].messages;
      if (message.type == types.MessageType.text &&
          !_trackUser.contains(message.author.firstName)) {
        _trackUser.add(message.author.firstName);

        _script.add({
          "text": message.text,
          "person": message.author.firstName,
          "language": _streamApi.detectLanguage(string: message.text)
        });
      }
    }

    setState(() {
      roles = _trackUser.toSet().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          children: [Text("hi")],
        )
      ],
    );
  }
}
