import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/dialogs/common_dialogs.dart';
import 'package:machi_app/helpers/app_localizations.dart';
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
  List<Script> scripts = [];
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
    setState(() {
      scripts = widget.scriptList;
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    double height = MediaQuery.of(context).size.height;

    return ReorderableListView(
        children: [
          for (int index = 0; index < scripts!.length; index += 1)
            Container(
                key: ValueKey(scripts[index].scriptId),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.grey),
                  ),
                ),
                child: ListTile(
                  isThreeLine: true,
                  title: const SizedBox.shrink(),
                  subtitle: _showScript(scripts[index]),
                  trailing: const Icon(Iconsax.menu_1),
                ))
        ],
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
          });
        });
  }

  Widget _showScript(Script script) {
    double width = MediaQuery.of(context).size.width;

    Widget icons = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Iconsax.edit,
              size: 20,
            )),
        IconButton(
            onPressed: () {
              _deleteMessage(script.scriptId);
            },
            icon: const Icon(
              Iconsax.trash,
              size: 20,
            ))
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => ImageSourceSheet(
        onImageSelected: (image) async {
          if (image != null) {
            Navigator.pop(context);

            try {
              var newMessage = {
                // ...author,
                'size': 19345,
                'height': 512,
                'width': 512,
                'type': 'image',
                'uri': image.path
              };
              // types.Message message = types.ImageMessage.fromJson(newMessage);
              // Scene newScene = Scene(
              //     seq: _copyStory.scene!.length - 1,
              //     sceneId: const Uuid().v4(),
              //     messages: message);
              // setState(() {
              //   _copyStory.scene!.add(newScene);
              // });
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
                  var newMessage = {
                    // ...author,
                    'type': 'text',
                    'text': text,
                  };
                  // types.Message message =
                  //     types.TextMessage.fromJson(newMessage);
                  // Scene newScene = Scene(
                  //     seq: _copyStory.scene!.length - 1,
                  //     sceneId:
                  //         SCENE_CUSTOM_FLAG + uuid.replaceAll(RegExp(r'-'), ''),
                  //     messages: message);
                  // setState(() {
                  //   _copyStory.scene!.add(newScene);
                  // });
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
    // for (Scene scene in scenes) {
    //   Scene updateSeq = scene.copyWith(seq: i);
    //   Map<String, dynamic> s = await formatStoryboard(updateSeq);
    //   newSequence.add({...s, STORY_ID: _copyStory.storyboardId});
    //   i++;
    // }
    // try {
    //   await _storyApi.updateSequence(newSequence);
    //   Get.back();
    // } catch (_) {
    //   Get.snackbar(
    //     _i18n.translate("error"),
    //     _i18n.translate("an_error_has_occurred"),
    //     snackPosition: SnackPosition.BOTTOM,
    //     backgroundColor: APP_ERROR,
    //   );
    // }
  }

  void _deleteMessage(dynamic scene) async {
    var message = scene.messages;
    confirmDialog(context,
        positiveText: _i18n.translate("OK"),
        message: _i18n.translate("story_sure_delete"),
        negativeAction: () => Navigator.of(context).pop(),
        positiveAction: () async {
          try {
            // if (message.id.contains(LOCAL_FLAG) == false) {
            //   await _storyApi.removeStory(message.id, _copyStory.storyboardId);
            // }
            // setState(() {
            //   _copyStory.scene!.remove(scene);
            // });

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
}
