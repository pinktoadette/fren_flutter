import 'dart:io';

import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/helpers/uploader.dart';
import 'package:fren_app/widgets/storyboard/edit_storyboard.dart';
import 'package:fren_app/widgets/storyboard/publish_story.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class PublishItemsWidget extends StatefulWidget {
  final Storyboard story;
  final Function(bool?) onCaptureImage;
  const PublishItemsWidget(
      {Key? key, required this.story, required this.onCaptureImage})
      : super(key: key);

  @override
  _PublishItemsWidgetState createState() => _PublishItemsWidgetState();
}

class _PublishItemsWidgetState extends State<PublishItemsWidget> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  File? _attachmentPreview;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          border: Border.all(width: 1.0, color: const Color(0xff707070)),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      _i18n.translate("storyboard"),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Iconsax.document)),
                ],
              ),
              const Divider(height: 5, thickness: 1),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextButton.icon(
                  icon: const Icon(Iconsax.edit, size: 27),
                  label: Text(_i18n.translate("edit"),
                      style: const TextStyle(fontSize: 16)),
                  onPressed: () async {
                    Get.to(const EditStory());
                  },
                ),
              ),
              const Divider(height: 5, thickness: 1),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextButton.icon(
                  icon: const Icon(Iconsax.document_text, size: 27),
                  label: Text(_i18n.translate("story_publish_time"),
                      style: const TextStyle(fontSize: 16)),
                  onPressed: () async {
                    _publishAsBoard();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextButton.icon(
                  icon: const Icon(Iconsax.sms, size: 27),
                  label: Text(_i18n.translate("story_as_email"),
                      style: const TextStyle(fontSize: 16)),
                  onPressed: () async {
                    _createEmail();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextButton.icon(
                  icon: const Icon(Iconsax.microphone, size: 27),
                  label: Text(_i18n.translate("story_as_audio"),
                      style: const TextStyle(fontSize: 16)),
                  onPressed: () async {
                    widget.onCaptureImage(true);
                  },
                ),
              ),
            ]));
  }

  void _publishAsBoard() {
    confirmDialog(context,
        icon: const Icon(Iconsax.warning_2),
        negativeAction: () => Navigator.of(context).pop(),
        negativeText: _i18n.translate("CANCEL"),
        message: _i18n.translate("publish_confirm"),
        positiveText: _i18n.translate("publish"),
        positiveAction: () {
          Navigator.of(context).pop();
          Get.to(PublishStory(story: widget.story));
        });
  }

  void _onHandleSubmitScene() async {
    if (_attachmentPreview != null) {
      String uri = await uploadFile(
          file: _attachmentPreview!,
          category: 'scene',
          categoryId: widget.story.storyboardId);
    }
  }

  void _createEmail() async {
    /// cant display images
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '',
      query: encodeQueryParameters(<String, String>{
        'subject': widget.story.title,
        'body': widget.story.scene!.map((s) {
          var obj = ((s.messages) as dynamic);
          switch (s.messages.type) {
            case (types.MessageType.text):
              return obj.text;
            default:
              break;
          }
        }).join(" ")
      }),
    );

    if (!await launchUrl(emailLaunchUri)) {
      throw Exception('Could not email');
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
