import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/script_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/create_uuid.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/image/image_rounded.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:machi_app/widgets/storyboard/bottom_sheets/add_text_collection.dart';

class EditPageReorder extends StatefulWidget {
  final List<Script> scriptList;
  final int? pageIndex;
  final int? numPages;
  final Function(List<Script> data) onUpdateSeq;
  final Function(List<StoryPages> data) onUpdateDelete;
  final Function(dynamic data) onMoveInsertPages;
  final Function(bool isClicked) onPreview;

  const EditPageReorder(
      {Key? key,
      required this.scriptList,
      required this.onUpdateDelete,
      required this.onMoveInsertPages,
      required this.onUpdateSeq,
      required this.onPreview,
      this.pageIndex = 0,
      this.numPages = 1})
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
                        confirmDismiss: (DismissDirection direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                    _i18n.translate("storybit_sure_delete")),
                                content: Text(
                                    _i18n.translate("storybit_sure_delete")),
                                actions: <Widget>[
                                  OutlinedButton(
                                      onPressed: () => {
                                            _deleteMessage(index),
                                            Navigator.of(context).pop(true),
                                          },
                                      child: Text(_i18n.translate("DELETE"))),
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(_i18n.translate("CANCEL"))),
                                ],
                              );
                            },
                          );
                        },
                        key: Key(scripts[index].scriptId ?? ""),
                        child: ListTile(
                          isThreeLine: true,
                          title: const SizedBox.shrink(),
                          subtitle: _showScript(index),
                          // trailing: const Icon(Iconsax.menu_1),
                        )))
            ],
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                Script item = scripts.removeAt(oldIndex);
                scripts.insert(newIndex, item);
                _updateSequence();
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
                          _addEditText();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.element_plus),
                        onPressed: () {
                          widget.onMoveInsertPages({"action": "add"});
                        },
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          widget.onPreview(true);
                        },
                        child: Text(_i18n.translate("storyboard_preview")),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ]),
              )
            ])),
      ],
    );
  }

  Widget _showScript(int index) {
    double width = MediaQuery.of(context).size.width;

    Widget icons = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
            onPressed: () {
              _addEditText(index: index);
            },
            icon: const Icon(
              Iconsax.edit,
              size: 16,
            )),
        PopupMenuButton<String>(
            icon: const Icon(Iconsax.forward_square, size: 16),
            initialValue: "1",
            // Callback that sets the selected popup menu item.
            onSelected: (item) {
              _moveBit(page: item, index: index);
            },
            itemBuilder: (BuildContext context) {
              return _showPages();
            }),
      ],
    );

    switch (scripts[index].type) {
      case "text":
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            scripts[index].text ?? "",
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          icons
        ]);
      case "image":
        return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RoundedImage(
                  width: width * 0.75,
                  height: width * 0.75,
                  icon: const Icon(Iconsax.image),
                  photoUrl: scripts[index].image?.uri ?? ""),
              icons
            ]);
      default:
        return const Icon(Iconsax.activity);
    }
  }

  List<PopupMenuItem<String>> _showPages() {
    return story.pages!.map((page) {
      return PopupMenuItem<String>(
        value: page.pageNum.toString(),
        child: Text(
            "${_i18n.translate("story_bit_move_page")} ${page.pageNum.toString()}"),
      );
    }).toList();
  }

  void _moveBit({required String page, required int index}) {
    widget.onMoveInsertPages({"page": page, "script": scripts[index]});
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
                _i18n.translate("story_edits_added"),
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

  void _addEditText({int? index}) async {
    String uuid = createUUID();
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        builder: (context) => AddEditText(
            text: index != null ? scripts[index].text : null,
            onTextComplete: (newText) async {
              try {
                if (index == null) {
                  Navigator.pop(context);
                  Script script = Script(
                      text: newText,
                      type: 'text',
                      characterName: UserModel().user.username,
                      scriptId: uuid,
                      status: ScriptStatus.ACTIVE.name,
                      seqNum: scripts.length);
                  await _scriptApi.addScriptToStory(
                    character: UserModel().user.username,
                    type: "text",
                    storyId: story.storyId,
                    text: newText,
                  );
                  setState(() {
                    scripts.add(script);
                  });
                }

                if (index != null) {
                  Navigator.pop(context);
                  Script script = Script(
                      text: newText,
                      type: 'text',
                      characterName: UserModel().user.username,
                      scriptId: scripts[index].scriptId,
                      status: ScriptStatus.ACTIVE.name,
                      seqNum: scripts[index].seqNum);
                  await _scriptApi.updateScript(script: script);

                  setState(() {
                    scripts[index] = script;
                  });
                  // update parent
                  // StoryPages page = story.pages[]
                  // widget.onUpdate(scripts);
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

  void _updateSequence() async {
    List<Script> newSequence = [];
    int i = 1;

    for (Script script in scripts) {
      Script updateSeq = script.copyWith(seqNum: i);
      newSequence.add(updateSeq);
      i++;
    }
    // update parent
    widget.onUpdateSeq(newSequence);
  }

  void _deleteMessage(int index) async {
    try {
      List<StoryPages> updatedScripts =
          await _scriptApi.deleteScript(script: scripts[index]);
      setState(() {
        scripts.removeAt(index);
      });
      // update parent
      widget.onUpdateDelete(updatedScripts);
    } catch (err) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }
}
