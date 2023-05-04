import 'dart:developer';
import 'dart:io';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/helpers/message_format.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/widgets/image_source_sheet.dart';
import 'package:fren_app/widgets/storyboard/bottom_sheets/add_scene.dart';
import 'package:fren_app/widgets/storyboard/view_storyboard.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';

class EditStory extends StatefulWidget {
  const EditStory({Key? key}) : super(key: key);

  @override
  _EditStoryState createState() => _EditStoryState();
}

class _EditStoryState extends State<EditStory> {
  String LOCAL_FLAG = 'LOCAL';
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  ChatController chatController = Get.find(tag: 'chatroom');
  bool _showName = false;
  final _storyApi = StoryApi();
  late Storyboard _copyStory;

  @override
  void initState() {
    _copyStory = storyboardController.currentStory.copyWith();
    setState(() {
      _showName = _copyStory.showNames ?? false;
    });
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
            Row(
              children: [
                Text(
                  _i18n.translate("story_show_names"),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: _showName,
                  onChanged: (newValue) async {
                    // Update UI
                    setState(() {
                      _showName = newValue;
                    });
                  },
                )
              ],
            ),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: _copyStory.scene == null
                ? const Text("No stories")
                : Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: ReorderableListView(
                          children: <Widget>[
                            for (int index = 0;
                                index < _copyStory.scene!.length;
                                index += 1)
                              Container(
                                  key: ValueKey(
                                      _copyStory.scene![index].sceneId),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1, color: Colors.grey),
                                    ),
                                  ),
                                  child: ListTile(
                                    isThreeLine: true,
                                    title: _showName == true
                                        ? Text(
                                            _copyStory.scene![index].messages
                                                .author.firstName!,
                                            style: const TextStyle(
                                                color: APP_ACCENT_COLOR,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          )
                                        : const SizedBox.shrink(),
                                    subtitle: _showMessage(
                                        context, _copyStory.scene![index]),
                                    trailing: const Icon(Iconsax.menu_1),
                                  ))
                          ],
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }

                              final Scene item =
                                  _copyStory.scene!.removeAt(oldIndex);
                              _copyStory.scene!.insert(newIndex, item);
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
                                  icon: const Icon(Iconsax.edit),
                                  onPressed: () {
                                    _addText();
                                  },
                                ),
                                const Spacer(),
                                OutlinedButton(
                                  onPressed: () {
                                    Get.to(
                                        () => ViewStory(showName: _showName));
                                  },
                                  child: Text(
                                      _i18n.translate("storyboard_preview")),
                                )
                              ]))
                    ],
                  )));
  }

  Widget _showMessage(BuildContext context, dynamic message) {
    final firstMessage = message.messages;
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
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            firstMessage.text,
            textAlign: TextAlign.left,
          ),
          icons
        ]);
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
            icons
          ],
        );
      default:
        return const Icon(Iconsax.activity);
    }
  }

  void _deleteMessage(dynamic scene) async {
    var message = scene.messages;
    confirmDialog(context,
        positiveText: _i18n.translate("OK"),
        message: _i18n.translate("story_sure_delete"),
        negativeAction: () => Navigator.of(context).pop(),
        positiveAction: () async {
          try {
            if (message.id.contains(LOCAL_FLAG) == false) {
              await _storyApi.removeStory(message.id, _copyStory.storyboardId);
            }
            setState(() {
              _copyStory.scene!.remove(scene);
            });

            Navigator.of(context).pop();
          } catch (err) {
            Get.snackbar(
              _i18n.translate("error"),
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

            try {
              var author = _authorObject();
              var newMessage = {
                ...author,
                'size': 19345,
                'height': 512,
                'width': 512,
                'type': 'image',
                'uri': image.path
              };
              types.Message message = types.ImageMessage.fromJson(newMessage);
              Scene newScene = Scene(
                  seq: _copyStory.scene!.length - 1,
                  sceneId: const Uuid().v4(),
                  messages: message);
              setState(() {
                _copyStory.scene!.add(newScene);
              });
              Get.snackbar(
                _i18n.translate("story_added"),
                _i18n.translate("story_added_info"),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: APP_SUCCESS,
              );
            } catch (err) {
              Get.snackbar(
                _i18n.translate("error"),
                _i18n.translate("an_error_has_occurred"),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: APP_ERROR,
              );
            }
          }
        },
      ),
    );
  }

  void _addText() async {
    String uuid = const Uuid().v4();

    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        builder: (context) => AddTextScene(onTextComplete: (text) async {
              try {
                if (text != null) {
                  Navigator.pop(context);
                  var author = _authorObject();
                  var newMessage = {
                    ...author,
                    'type': 'text',
                    'text': text,
                  };
                  types.Message message =
                      types.TextMessage.fromJson(newMessage);
                  Scene newScene = Scene(
                      seq: _copyStory.scene!.length - 1,
                      sceneId:
                          SCENE_CUSTOM_FLAG + uuid.replaceAll(RegExp(r'-'), ''),
                      messages: message);
                  setState(() {
                    _copyStory.scene!.add(newScene);
                  });
                }
                Get.snackbar(
                  _i18n.translate("story_added"),
                  _i18n.translate("story_added_info"),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: APP_SUCCESS,
                );
              } catch (err) {
                Get.snackbar(
                  _i18n.translate("error"),
                  _i18n.translate("an_error_has_occurred"),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: APP_ERROR,
                );
              }
            }));
  }

  Map<String, dynamic> _authorObject() {
    String id = const Uuid().v4();
    return {
      'id': '${LOCAL_FLAG}_$id',
      'name': UserModel().user.userFullname,
      'author': {
        'id': UserModel().user.userId,
        'firstName': UserModel().user.username,
      }
    };
  }

  void _saveStory() async {
    List<Scene> scenes = _copyStory.scene!;
    List<Map<String, dynamic>> newSequence = [];
    int i = 1;
    for (Scene scene in scenes) {
      Scene updateSeq = scene.copyWith(seq: i);
      Map<String, dynamic> s = await formatStoryboard(updateSeq);
      newSequence.add({
        ...s,
        STORY_SHOW_NAMES: _showName,
        STORY_ID: _copyStory.storyboardId
      });
      i++;
    }
    try {
      log(newSequence.toString());
      await _storyApi.updateSequence(newSequence);
    } catch (_) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }
}
