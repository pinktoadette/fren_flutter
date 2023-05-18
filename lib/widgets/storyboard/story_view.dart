import 'dart:io';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// View details of each message
class StoryViewDetails extends StatefulWidget {
  final Storyboard storyboard;
  const StoryViewDetails({Key? key, required this.storyboard})
      : super(key: key);

  @override
  _StoryViewState createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryViewDetails> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: widget.storyboard.story!.length,
        itemBuilder: (BuildContext ctx, index) {
          return ListTile(
            isThreeLine: true,
            title: Text(widget.storyboard.story![index].title),
            subtitle: Text(widget.storyboard.story![index].subtitle),
          );
        });
  }

  Widget _showMessage(BuildContext context, dynamic message) {
    final firstMessage = message;
    return const Text("hi");
    switch (firstMessage.type) {
      case (types.MessageType.text):
        return Text(firstMessage.text);
      case (types.MessageType.image):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: firstMessage.uri.startsWith('http') == true
                  ? Image.network(
                      firstMessage.uri,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(firstMessage.uri),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            )),
          ],
        );
      default:
        return const Icon(Iconsax.activity);
    }
  }
}
