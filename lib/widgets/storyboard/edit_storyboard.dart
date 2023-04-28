import 'dart:io';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/image_source_sheet.dart';
import 'package:fren_app/widgets/storyboard/add_scene.dart';
import 'package:fren_app/widgets/storyboard/preview_storyboard.dart';
import 'package:fren_app/widgets/storyboard/publish_story.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class EditStory extends StatefulWidget {
  final Storyboard story;
  final int storyIdx;
  const EditStory({Key? key, required this.story, required this.storyIdx})
      : super(key: key);

  @override
  _EditStoryState createState() => _EditStoryState();
}

class _EditStoryState extends State<EditStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final _storyApi = StoryApi();
  late Storyboard _original;
  File? _attachmentPreview;

  @override
  void initState() {
    _original = widget.story.copyWith();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            _i18n.translate("storyboard_edit"),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              _saveStory();
              Get.back();
            },
          ),
          actions: [
            // Save changes button
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Text(_i18n.translate("publish")),
                  onPressed: () {
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
                  },
                ))
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: widget.story.scene == null
                ? const Text("No stories")
                : Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: ReorderableListView(
                          children: <Widget>[
                            for (int index = 0;
                                index < widget.story.scene!.length;
                                index += 1)
                              Container(
                                  key: ValueKey(widget.story.scene![index].seq),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1, color: Colors.grey),
                                    ),
                                  ),
                                  child: ListTile(
                                    isThreeLine: true,
                                    title: Text(widget.story.scene![index]
                                        .messages.author.firstName!),
                                    subtitle: _showMessage(context,
                                        widget.story.scene![index].messages),
                                    trailing: const Icon(Iconsax.menu_1),
                                  ))
                          ],
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }

                              final Scene item =
                                  widget.story.scene!.removeAt(oldIndex);
                              widget.story.scene!.insert(newIndex, item);
                            });
                          },
                        ),
                      ),
                      Positioned(
                          width: width - 50,
                          bottom: 0,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: const Icon(Iconsax.gallery_add),
                                  onPressed: () {
                                    _addImage();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Iconsax.pen_add),
                                  onPressed: () {
                                    _addText();
                                  },
                                ),
                                const Spacer(),
                                OutlinedButton(
                                  onPressed: () {
                                    Get.to(PreviewStory(story: widget.story));
                                  },
                                  child: Text(
                                      _i18n.translate("storyboard_preview")),
                                )
                              ]))
                    ],
                  )));
  }

  Widget _showMessage(BuildContext context, dynamic message) {
    final firstMessage = message;
    Widget icons = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
            onPressed: () {
              _deleteMessage(message);
            },
            icon: const Icon(
              Iconsax.trash,
              size: 20,
            ))
      ],
    );
    switch (firstMessage.type) {
      case (types.MessageType.text):
        return Column(children: [Text(firstMessage.text), icons]);
      case (types.MessageType.image):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                firstMessage.uri,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )),
            icons
          ],
        );
      default:
        return const Icon(Iconsax.activity);
    }
  }

  void _deleteMessage(dynamic message) async {
    confirmDialog(context,
        positiveText: _i18n.translate("OK"),
        message: _i18n.translate("story_sure_delete"),
        negativeAction: () => Navigator.of(context).pop(),
        positiveAction: () async {
          try {
            await _storyApi.removeStory(
                widget.storyIdx, message.id, widget.story.storyboardId);
            Navigator.of(context).pop();
          } catch (_) {
            Get.snackbar(
              'Error',
              _i18n.translate("an_error_has_occurred"),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: APP_ERROR,
            );
          }
        });
  }

  void _addImage() async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => ImageSourceSheet(
        onImageSelected: (image) async {
          if (image != null) {
            Navigator.pop(context);
            setState(() {
              _attachmentPreview = image;
            });
          }
        },
      ),
    );
  }

  void _addText() async {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        builder: (context) => AddSceneBoard(story: widget.story));
  }

  void _saveStory() async {
    List<Scene> scenes = widget.story.scene!;
    List<Map<String, dynamic>> newSequence = [];
    int i = 1;
    for (Scene scene in scenes) {
      Map<String, dynamic> s = {
        STORY_SCENE_SEQ: i,
        STORY_SCENE_ID: scene.sceneId
      };
      newSequence.add(s);
      i++;
    }
    try {
      await _storyApi.updateSequence(newSequence);
    } catch (_) {
      Get.snackbar(
        'Error',
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }
}
