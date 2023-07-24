import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/script_api.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/create_uuid.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/common/chat_bubble_container.dart';
import 'package:machi_app/widgets/decoration/text_border.dart';
import 'package:machi_app/widgets/image/image_rounded.dart';
import 'package:machi_app/widgets/storyboard/bottom_sheets/add_edit_text.dart';
import 'package:machi_app/widgets/storyboard/my_edit/edit_page_background.dart';
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';
import 'package:machi_app/widgets/storyboard/my_edit/page_direction_edit.dart';

// ignore: must_be_immutable
class EditPageReorder extends StatefulWidget {
  Story story;
  final List<Script> scriptList;
  final int pageIndex;
  final Function(List<Script> data) onUpdateSeq;
  final Function(dynamic data) onMoveInsertPages;
  final Function(Layout data) onLayoutSelection;
  final Function(PageDirection direction) onPageAxisDirection;
  Layout? layout;

  EditPageReorder(
      {Key? key,
      required this.story,
      required this.scriptList,
      required this.onMoveInsertPages,
      required this.onUpdateSeq,
      required this.onLayoutSelection,
      required this.onPageAxisDirection,
      this.pageIndex = 0,
      this.layout})
      : super(key: key);

  @override
  _EditPageReorderState createState() => _EditPageReorderState();
}

class _EditPageReorderState extends State<EditPageReorder> {
  final _scriptApi = ScriptApi();
  late List<Script> scripts;
  late Story story;
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  Layout? layout;
  File? attachmentPreview;
  String? urlPreview;
  double _alphaValue = 0.5;
  PageDirection _direction = PageDirection.HORIZONTAL;

  @override
  void initState() {
    super.initState();
    setState(() {
      scripts = widget.scriptList;
      story = storyboardController.currentStory;
      layout = widget.layout;
      urlPreview = story.pages![widget.pageIndex].backgroundImageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        _reorderListWidget(),
        Positioned(
            height: 100,
            bottom: 0,
            child: Column(children: [
              Container(
                color: Theme.of(context).colorScheme.background,
                width: size.width,
                height: 100,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.text_block),
                        onPressed: () {
                          _addEditText();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.image),
                        onPressed: () {
                          _editPageImage(context);
                        },
                      ),
                      IconButton(
                        icon: _direction == PageDirection.HORIZONTAL
                            ? const Icon(Icons.swipe_right)
                            : const Icon(Icons.swipe_down),
                        onPressed: () {
                          _editPageDirection(context);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.grid_3),
                        onPressed: () {
                          _showLayOutSelection(context);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.element_plus),
                        onPressed: () {
                          widget.onMoveInsertPages({"action": "add"});
                        },
                      ),
                    ]),
              )
            ])),
      ],
    );
  }

  /// drag and drop of individual widget
  /// it saves after each change.
  Widget _reorderListWidget() {
    Size size = MediaQuery.of(context).size;
    if (scripts.isEmpty || scripts[0].scriptId == "") {
      return Container(
        width: size.width,
      );
    }

    return Container(
        margin: const EdgeInsets.only(bottom: 100),
        constraints: BoxConstraints(minHeight: size.width),
        decoration: BoxDecoration(
          image: DecorationImage(
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(_alphaValue), BlendMode.darken),
              image: attachmentPreview != null
                  ? FileImage(
                      attachmentPreview!,
                    )
                  : urlPreview != null
                      ? CachedNetworkImageProvider(
                          urlPreview!,
                          errorListener: () => const Icon(Icons.error),
                        )
                      : story.pages![widget.pageIndex].backgroundImageUrl !=
                              null
                          ? CachedNetworkImageProvider(
                              story
                                  .pages![widget.pageIndex].backgroundImageUrl!,
                              errorListener: () => const Icon(Icons.error),
                            )
                          : Image.asset(
                              "assets/images/machi.png",
                              scale: 0.2,
                              width: 100,
                            ).image,
              fit: BoxFit.cover),
        ),
        child: ReorderableListView(
            children: [
              for (int index = 0; index < scripts.length; index += 1)
                Container(
                    key: ValueKey(scripts[index].scriptId),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1, color: APP_TERTIARY),
                      ),
                    ),
                    child: Dismissible(
                        confirmDismiss: (DismissDirection direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  _i18n.translate("DELETE"),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
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
                                            _deleteBit(index),
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
            }));
  }

  /// shows how individual text / images inside the box,
  /// such as text alignment
  Widget _showScript(int index) {
    Size size = MediaQuery.of(context).size;
    CrossAxisAlignment alignment = layout == Layout.CONVO
        ? story.createdBy.username == scripts[index].characterName
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start
        : CrossAxisAlignment.start;
    Widget icons = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
            onPressed: () {
              if (scripts[index].type == "text") {
                _addEditText(index: index);
              } else {
                null;
              }
            },
            icon: const Icon(
              Iconsax.edit,
              size: 16,
            )),
        PopupMenuButton<int>(
            icon: const Icon(Iconsax.document_forward, size: 16),
            initialValue: 1,
            // Callback that sets the selected popup menu item.
            onSelected: (num) async {
              int pageNum = num;
              if (num == story.pages!.length) {
                widget.onMoveInsertPages({"action": "add"});
                pageNum += 1;
              }
              _moveBit(pageNum: pageNum, scriptIndex: index);
            },
            itemBuilder: (BuildContext context) {
              return _showPages();
            }),
      ],
    );

    // layout
    Widget lay = (layout == Layout.CONVO)
        ? Row(
            mainAxisAlignment: alignment == CrossAxisAlignment.end
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(scripts[index].characterName ?? ""),
            ],
          )
        : const SizedBox.shrink();

    switch (scripts[index].type) {
      case "text":
        return Column(crossAxisAlignment: alignment, children: [
          const SizedBox(
            height: 30,
          ),
          _bubbleOrNot(
              layout != Layout.CONVO
                  ? SizedBox(
                      width: size.width,
                      child: TextBorder(
                          text: scripts[index].text ?? "",
                          size: 16,
                          textAlign: scripts[index].textAlign))
                  : Text(
                      scripts[index].text ?? "",
                      textAlign: scripts[index].textAlign,
                      style: TextStyle(
                          color: layout == Layout.CONVO
                              ? Colors.black
                              : APP_INVERSE_PRIMARY_COLOR,
                          fontSize: 16),
                    ),
              size,
              alignment),
          lay,
          icons
        ]);
      case "image":
        return Column(crossAxisAlignment: alignment, children: <Widget>[
          const SizedBox(
            height: 30,
          ),
          _bubbleOrNot(
              RoundedImage(
                  width: size.width * 0.75,
                  height: size.width * 0.75,
                  icon: const Icon(Iconsax.image),
                  photoUrl: scripts[index].image?.uri ?? ""),
              size,
              alignment),
          lay,
          icons
        ]);
      default:
        return const Icon(Iconsax.activity);
    }
  }

  /// layout conversation style or plain text style
  Widget _bubbleOrNot(Widget widget, Size size, CrossAxisAlignment align) {
    return layout == Layout.CONVO
        ? StoryBubble(
            isRight: align == CrossAxisAlignment.end,
            widget: widget,
            size: size,
          )
        : widget;
  }

  /// show all the pages in the collection.
  List<PopupMenuItem<int>> _showPages() {
    story = storyboardController.currentStory;

    List<PopupMenuItem<int>> pagesMenu = story.pages!.map((page) {
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
    pagesMenu.add(PopupMenuItem<int>(
        value: story.pages!.length,
        child: Text(_i18n.translate("story_bit_add_to_new_page"))));
    return pagesMenu;
  }

  /// select layouy format. Three choices.
  void _showLayOutSelection(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 0.4,
            child: StoryLayout(
              selection: layout ?? Layout.CONVO,
              onSelection: (value) {
                setState(() {
                  layout = value;
                });
                widget.onLayoutSelection(value);
                if (value == Layout.COMIC) {
                  setState(() {
                    _alphaValue = 0;
                  });
                }
              },
            ));
      },
    ).whenComplete(() {
      _updateBackground();
    });
  }

  /// drag and drop individual boxes.
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
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Unable to move message bits', fatal: true);
    }
  }

  /// add or edit texts for individual boxes.
  void _addEditText({int? index}) async {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        builder: (context) => AddEditText(
            text: index != null ? scripts[index].text : null,
            onTextComplete: (newContent) async {
              try {
                if ((index == null) & (newContent != null)) {
                  await _saveOrUploadTextImg(newContent!);
                  Navigator.pop(context);
                }

                if ((index != null) & (newContent?["text"] != "")) {
                  Script script = scripts[index!].copyWith(
                      text: newContent?["text"] ?? "",
                      textAlign: newContent?["textAlign"] ?? TextAlign.left);

                  await _scriptApi.updateScript(script: script);

                  setState(() {
                    scripts[index] = script;
                  });
                  Navigator.pop(context);
                }

                widget.onUpdateSeq(scripts);
                Get.snackbar(_i18n.translate("story_added"),
                    _i18n.translate("story_added_info"),
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: APP_SUCCESS,
                    colorText: Colors.black);
              } catch (err, s) {
                Get.snackbar(
                  _i18n.translate("error"),
                  _i18n.translate("an_error_has_occurred"),
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: APP_ERROR,
                );
                await FirebaseCrashlytics.instance.recordError(err, s,
                    reason: 'Unable to save add/edit text in bits ',
                    fatal: true);
              }
            }));
  }

  /// save any images texts.
  Future<void> _saveOrUploadTextImg(Map<String, dynamic> content) async {
    if (content["text"] != "") {
      StoryPages pages = await _scriptApi.addScriptToStory(
          character: UserModel().user.username,
          characterId: UserModel().user.userId,
          type: "text",
          storyId: story.storyId,
          text: content["text"] ?? "",
          textAlign: content["textAlign"] ?? TextAlign.left,
          pageNum: widget.pageIndex + 1);
      setState(() {
        scripts = [...scripts, pages.scripts![0]];
      });
    }
    if (content["image"] != "") {
      String uploadImage = await uploadFile(
          file: content["image"],
          category: UPLOAD_PATH_SCRIPT_IMAGE,
          categoryId: createUUID());
      var bytes = content["image"].readAsBytesSync();
      var result = await decodeImageFromList(bytes);

      StoryPages pages = await _scriptApi.addScriptToStory(
          character: UserModel().user.username,
          characterId: UserModel().user.userId,
          type: "image",
          storyId: story.storyId,
          image: {
            "size": bytes.length,
            "height": result.height.toDouble(),
            "width": result.width.toDouble(),
            "uri": uploadImage,
            "manual": true
          },
          pageNum: widget.pageIndex + 1);
      setState(() {
        scripts = [...scripts, pages.scripts![0]];
      });
    }

    if (content["gallery"] != "") {
      StoryPages pages = await _scriptApi.addScriptToStory(
          character: UserModel().user.username,
          characterId: UserModel().user.userId,
          type: "image",
          storyId: story.storyId,
          image: {
            "size": 9800,
            "height": 516,
            "width": 516,
            "uri": content['gallery'],
            "manual": true
          },
          pageNum: widget.pageIndex + 1);
      setState(() {
        scripts = [...scripts, pages.scripts![0]];
      });
    }
    widget.onUpdateSeq(scripts);
  }

  /// updates the sequence of the individual boxes when dragged and dropped.
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
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Unable to update sequence', fatal: true);
    }
  }

  /// delete individual boxes.
  void _deleteBit(int index) async {
    try {
      await _scriptApi.deleteScript(script: scripts[index]);
      scripts
          .removeWhere((script) => script.scriptId == scripts[index].scriptId);
      setState(() {
        scripts = [...scripts];
      });
      widget.onUpdateSeq(scripts);
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Unable to delete message in edit bits', fatal: true);
    }
  }

  /// update background images on the page.
  void _updateBackground() async {
    final _storyApi = StoryApi();
    String? url = urlPreview;
    if (attachmentPreview != null) {
      url = await uploadFile(
          file: attachmentPreview!,
          category: UPLOAD_PATH_SCRIPT_IMAGE,
          categoryId: createUUID());

      /// delete last uploadfile
    }
    StoryPages storyPages = story.pages![widget.pageIndex];
    storyPages.backgroundImageUrl = url;
    storyPages.backgroundAlpha = _alphaValue;
    story.pages![story.pages!
            .indexWhere((element) => element.pageNum == widget.pageIndex + 1)] =
        storyPages;

    Story updateStory =
        story.copyWith(pages: story.pages, pageDirection: _direction);

    await _storyApi.updateStory(story: updateStory);
    setState(() {
      story = updateStory;
    });
  }

  /// edit background image of the page.
  void _editPageImage(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        barrierColor: Colors.black.withOpacity(_alphaValue),
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.7,
              child: EditPageBackground(
                  passStory: story,
                  alpha: _alphaValue,
                  backgroundImage:
                      story.pages![widget.pageIndex].backgroundImageUrl,
                  onGallerySelect: (value) => {
                        setState(() {
                          urlPreview = value;
                          attachmentPreview = null;
                        }),
                      },
                  onAlphaChange: (value) => {
                        setState(() {
                          _alphaValue = value;
                        })
                      },
                  onImageSelect: (value) => {
                        setState(() {
                          attachmentPreview = value;
                          urlPreview = null;
                        }),
                      }),
            )).whenComplete(() {
      _updateBackground();
    });
  }

  /// edit page direction scroll.
  /// PageDirection.HORIZONTAL or PageDirection.VERTICAL.
  void _editPageDirection(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        barrierColor: Colors.black.withOpacity(_alphaValue),
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.7,
              child: PageScrollDirection(
                selection: _direction,
                onSelection: (direction) {
                  setState(() {
                    _direction = direction;
                  });
                  widget.onPageAxisDirection(direction);
                },
              ),
            )).whenComplete(() {
      _updateBackground();
    });
  }
}
