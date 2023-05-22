import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/script_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/dialogs/common_dialogs.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/create_uuid.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/image/image_rounded.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:machi_app/widgets/storyboard/bottom_sheets/add_scene.dart';
import 'package:uuid/uuid.dart';

class EditPageReorder extends StatefulWidget {
  final List<Script> scriptList;
  final Function(dynamic data) onUpdate;

  const EditPageReorder(
      {Key? key, required this.scriptList, required this.onUpdate})
      : super(key: key);

  @override
  _EditPageReorderState createState() => _EditPageReorderState();
}

class _EditPageReorderState extends State<EditPageReorder> {
  // ignore: constant_identifier_names
  static const LOCAL_FLAG = "LOCAL_";
  final _scriptApi = ScriptApi();
  List<Script> scripts = [];
  late Story story;
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    super.initState();
    setState(() {
      scripts = widget.scriptList;
      story = storyboardController.currentStory;
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        ReorderableListView(
            children: [
              for (int index = 0; index < scripts.length; index += 1)
                Container(
                    key: ValueKey(scripts[index].scriptId),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: Dismissible(
                        key: Key(scripts[index].scriptId!),
                        onDismissed: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            _deleteMessage(scripts[index]);
                            setState(() {
                              scripts.removeAt(index);
                            });
                          }
                        },
                        child: ListTile(
                          isThreeLine: true,
                          title: const SizedBox.shrink(),
                          subtitle: _showScript(scripts[index]),
                          trailing: const Icon(Iconsax.menu_1),
                        )))
            ],
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                Script item = scripts.removeAt(oldIndex);
                scripts.insert(newIndex, item);
              });
            }),
        Positioned(
            width: width,
            bottom: 0,
            child: Column(children: [
              Container(
                color: Theme.of(context).colorScheme.background,
                width: width,
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
                        icon: const Icon(Iconsax.text),
                        onPressed: () {
                          _addText();
                        },
                      ),
                      // IconButton(
                      //   icon: const Icon(Iconsax.music),
                      //   onPressed: () {},
                      // ),
                      // IconButton(
                      //   icon: const Icon(Iconsax.voice_square),
                      //   onPressed: () {
                      //     // _changeVoice();
                      //   },
                      // ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          // Get.to(() => ViewStory(showName: _showName));
                        },
                        child: Text(_i18n.translate("storyboard_preview")),
                      )
                    ]),
              )
            ])),
      ],
    );
  }

  Widget _showScript(Script script) {
    double width = MediaQuery.of(context).size.width;

    Widget icons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Iconsax.edit,
              size: 16,
            )),
      ],
    );

    switch (script.type) {
      case "text":
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            script.text ?? "",
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          icons
        ]);
      case "image":
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RoundedImage(
                  width: width * 0.75,
                  height: width * 0.75,
                  icon: const Icon(Iconsax.image),
                  photoUrl: script.image?.uri ?? ""),
              icons
            ]);
      default:
        return const Icon(Iconsax.activity);
    }
  }

  void _addImage() async {
    String uuid = createUUID();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => ImageSourceSheet(
        onImageSelected: (image) async {
          if (image != null) {
            Navigator.pop(context);

            try {
              ScriptImage scriptImage = ScriptImage(
                  size: 19345, height: 512, width: 512, uri: image.path);
              Script script = Script(
                  characterName: UserModel().user.username,
                  image: scriptImage,
                  type: 'image',
                  scriptId: uuid,
                  status: ScriptStatus.ACTIVE.name,
                  seqNum: scripts.length);
              setState(() {
                scripts.add(script);
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
    String uuid = createUUID();
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        builder: (context) => AddTextScene(onTextComplete: (text) async {
              try {
                if (text != null) {
                  Navigator.pop(context);
                  Script script = Script(
                      text: text,
                      type: 'text',
                      characterName: UserModel().user.username,
                      scriptId: uuid,
                      status: ScriptStatus.ACTIVE.name,
                      seqNum: scripts.length);
                  await _scriptApi.addScriptToStory(
                    character: UserModel().user.username,
                    type: "text",
                    storyId: story.storyId,
                    text: text,
                  );
                  setState(() {
                    scripts.add(script);
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

  void _saveStory() async {
    List<Script> script = scripts;
    List<Map<String, dynamic>> newSequence = [];
    int i = 1;

    for (Script script in scripts) {
      Script updateSeq = script.copyWith(seqNum: i);
      Map<String, dynamic> newSeq = updateSeq.toJSON();
      newSequence.add({...newSeq, STORY_ID: story.storyId});
      i++;
    }
    try {
      await _scriptApi.updateSequence(scripts: newSequence);
      Get.back();
    } catch (_) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
      // }
    }
  }

  void _deleteMessage(Script script) async {
    confirmDialog(context,
        positiveText: _i18n.translate("OK"),
        message: _i18n.translate("story_sure_delete"),
        negativeAction: () => Navigator.of(context).pop(),
        positiveAction: () async {
          try {
            if (script.scriptId?.contains(LOCAL_FLAG) == false) {
              await _scriptApi.deleteScript(script: script);
            }
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
}
