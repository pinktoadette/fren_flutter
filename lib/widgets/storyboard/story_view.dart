import 'dart:io';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// View story details by list
class StoryViewDetails extends StatefulWidget {
  final Storyboard story;
  const StoryViewDetails({Key? key, required this.story}) : super(key: key);

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
        itemCount: widget.story.scene!.length,
        itemBuilder: (BuildContext ctx, index) {
          final message = widget.story.scene![index].messages;

          return ListTile(
            isThreeLine: true,
            title: widget.story.showNames == true
                ? Text(
                    widget.story.scene![index].messages.author.firstName!,
                    style: const TextStyle(
                        color: APP_ACCENT_COLOR,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  )
                : const SizedBox.shrink(),
            subtitle: _showMessage(context, message),
          );
        });
  }

  Widget _showMessage(BuildContext context, dynamic message) {
    final firstMessage = message;

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
