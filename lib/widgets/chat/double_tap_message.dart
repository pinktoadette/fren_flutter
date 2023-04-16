import 'package:flutter/material.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/widgets/storyboard/add_storyboard.dart';

// ignore: must_be_immutable
class DoubleTapChatMessage extends StatefulWidget {
  types.Message message;
  DoubleTapChatMessage({Key? key, required this.message}) : super(key: key);

  @override
  _DoubleTapChatMessageState createState() => _DoubleTapChatMessageState();
}

class _DoubleTapChatMessageState extends State<DoubleTapChatMessage> {
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _i18n.translate("message_share"),
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            /// Display a list of story
            AddStoryBoard(
              message: widget.message,
            ),
          ],
        ));
  }
}
