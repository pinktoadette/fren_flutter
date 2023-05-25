import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/script_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/image/image_rounded.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:machi_app/widgets/storyboard/bottom_sheets/add_text_collection.dart';

class EditPageReorder extends StatefulWidget {
  final List<Script> scriptList;
  final int pageIndex;
  final Function(List<Script> data) onUpdateSeq;
  final Function(List<StoryPages> data) onUpdateDelete;
  final Function(dynamic data) onMoveInsertPages;

  const EditPageReorder(
      {Key? key,
      required this.scriptList,
      required this.onUpdateDelete,
      required this.onMoveInsertPages,
      required this.onUpdateSeq,
      this.pageIndex = 0})
      : super(key: key);

  @override
  _EditPageReorderState createState() => _EditPageReorderState();
}

class _EditPageReorderState extends State<EditPageReorder> {
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
                                title: Text(_i18n.translate("DELETE")),
                                content: Text(
                                    _i18n.translate("storybit_sure_delete")),
                                actions: <Widget>[
                                  OutlinedButton(
                                      onPressed: () => {
                                            Navigator.of(context).pop(false),
                                          },
                                      child: Text(_i18n.translate("CANCEL"))),
                                  const SizedBox(
                                    width: 50,
                                  ),
                                  ElevatedButton(
                                      onPressed: () => {
                                            _deleteMessage(index),
                                            Navigator.of(context).pop(true),
                                          },
                                      child: Text(_i18n.translate("DELETE"))),
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
        PopupMenuButton<int>(
            icon: const Icon(Iconsax.forward_square, size: 16),
            initialValue: 1,
            // Callback that sets the selected popup menu item.
            onSelected: (item) {
              _moveBit(pageNum: item, scriptIndex: index);
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

  List<PopupMenuItem<int>> _showPages() {
    story = storyboardController.currentStory;

    return story.pages!.map((page) {
      if (page.pageNum != (widget.pageIndex + 1)) {
        return PopupMenuItem<int>(
          value: page.pageNum,
          child: Text(
              "${_i18n.translate("story_bit_move_page")} ${page.pageNum.toString()}"),
        );
      }
      return PopupMenuItem<int>(
        value: null,
        child: Text(_i18n.translate("story_bit_on_current_page")),
      );
    }).toList();
  }

  void _moveBit({required int pageNum, required int scriptIndex}) async {
    try {
      Script script = scripts[scriptIndex].copyWith(pageNum: pageNum);
      await _scriptApi.updateScript(script: script);

      // update child state, scripts
      scripts.removeWhere(
          (script) => script.scriptId == scripts[scriptIndex].scriptId);
      setState(() {
        scripts = scripts;
      });
      widget.onMoveInsertPages(
          {"action": "move", "page": pageNum, "script": script});
    } catch (err) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
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
              await _scriptApi.addScriptToStory(
                  character: UserModel().user.username,
                  type: "image",
                  storyId: story.storyId,
                  image: {
                    "size": 19345,
                    "height": 512,
                    "width": 512,
                    "uri": image.path
                  },
                  pageNum: widget.pageIndex + 1);

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
                  StoryPages pages = await _scriptApi.addScriptToStory(
                      character: UserModel().user.username,
                      type: "text",
                      storyId: story.storyId,
                      text: newText,
                      pageNum: widget.pageIndex + 1);
                  setState(() {
                    scripts.add(pages.scripts![0]);
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
    List<Map<String, dynamic>> saveSequence = [];
    int i = 1;

    for (Script script in scripts) {
      Script updateSeq = script.copyWith(seqNum: i);
      newSequence.add(updateSeq);
      saveSequence.add({"seqNum": i, "scriptId": updateSeq.scriptId});
      i++;
    }
    // update parent
    widget.onUpdateSeq(newSequence);

    try {
      await _scriptApi.updateSequence(scripts: saveSequence);
    } catch (err) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }

  void _deleteMessage(int index) async {
    try {
      List<StoryPages> updatedScripts =
          await _scriptApi.deleteScript(script: scripts[index]);

      scripts
          .removeWhere((script) => script.scriptId == scripts[index].scriptId);
      setState(() {
        scripts = scripts;
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
