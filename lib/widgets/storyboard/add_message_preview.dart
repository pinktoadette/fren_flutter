import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/widgets/story_cover.dart';

class PreviewMessageToAdd extends StatefulWidget {
  final types.Message message;
  const PreviewMessageToAdd({Key? key, required this.message})
      : super(key: key);

  @override
  _PreviewMessageToAddState createState() => _PreviewMessageToAddState();
}

class _PreviewMessageToAddState extends State<PreviewMessageToAdd> {
  @override
  Widget build(BuildContext context) {
    dynamic message = widget.message;

    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Adding item: ", style: Theme.of(context).textTheme.labelMedium),
          SizedBox(
              height: 70,
              child: message.type == types.MessageType.text
                  ? Text(message.text,
                      overflow: TextOverflow.fade,
                      style: Theme.of(context).textTheme.labelSmall)
                  : StoryCover(
                      width: 70,
                      radius: 10,
                      photoUrl: message.uri,
                      title: "image"))
        ]));
  }
}
