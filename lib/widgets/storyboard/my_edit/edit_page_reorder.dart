import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/script_api.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/add_edit_text.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/dialogs/progress_dialog.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/create_uuid.dart';
import 'package:machi_app/helpers/downloader.dart';
import 'package:machi_app/helpers/image_aspect_ratio.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/helpers/theme_helper.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/common/chat_bubble_container.dart';
import 'package:machi_app/widgets/decoration/text_border.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/bottom_sheets/add_edit_text.dart';
import 'package:machi_app/widgets/storyboard/my_edit/add_ai_image.dart';
import 'package:machi_app/widgets/storyboard/my_edit/edit_page_background.dart';
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';
import 'package:machi_app/widgets/storyboard/my_edit/page_direction_edit.dart';
import 'dart:ui' as ui;

// ignore: must_be_immutable
class EditPageReorder extends StatefulWidget {
  Story story;
  final List<Script> scriptList;
  final int pageIndex;
  final Function(List<Script> data) onUpdateSeq;
  final Function(dynamic data) onMoveInsertPages;
  final Function(Layout data) onLayoutSelection;
  final Function(PageDirection direct) onPageAxisDirection;
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
  State<EditPageReorder> createState() => _EditPageReorderState();
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
  double _alphaValue = 0.25;
  late ProgressDialog _pr;
  final PageDirection _direction = PageDirection.VERTICAL;

  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      scripts = widget.scriptList;
      story = storyboardController.currentStory;
      layout = widget.layout;
      urlPreview = story.pages![widget.pageIndex].backgroundImageUrl;
    });
    bool isDarkMode = ThemeHelper().loadThemeFromBox();
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    _pr = ProgressDialog(context, isDismissible: false);

    return Stack(
      children: [
        _reorderListWidget(),
        Positioned(
            height: 70,
            bottom: Platform.isAndroid ? 0 : 30,
            child: Column(children: [
              Container(
                color: Theme.of(context).colorScheme.background,
                width: size.width,
                height: 70,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.text_block),
                        onPressed: () {
                          _editPageText();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.image),
                        onPressed: () {
                          _aiImage();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.gallery),
                        onPressed: () {
                          _editPageImage();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.grid_3),
                        onPressed: () {
                          _showLayOutSelection();
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
          color: Theme.of(context).colorScheme.background,
          image: DecorationImage(
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(_alphaValue), BlendMode.darken),
              image: attachmentPreview != null
                  ? FileImage(
                      attachmentPreview!,
                    )
                  : urlPreview != null
                      ? ImageCacheWrapper(urlPreview!)
                      : story.pages![widget.pageIndex].backgroundImageUrl !=
                              null
                          ? ImageCacheWrapper(story
                              .pages![widget.pageIndex].backgroundImageUrl!)
                          : const AssetImage(
                              "assets/images/blank.png",
                            ),
              fit: BoxFit.cover),
        ),
        child: ReorderableListView(
            children: [
              for (int index = 0; index < scripts.length; index += 1)
                Container(
                    key: ValueKey(scripts[index].scriptId),
                    margin: const EdgeInsets.only(left: 20, top: 0, bottom: 10),
                    child: Dismissible(
                        key: UniqueKey(),
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
    Color textColor = _isDarkMode ? Colors.white54 : Colors.black;

    CrossAxisAlignment alignment = layout == Layout.CONVO
        ? story.createdBy.userId == scripts[index].characterId
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start
        : CrossAxisAlignment.start;
    Widget icons = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
            onPressed: () {
              _editPageText(index: index);
            },
            icon: const Icon(
              Iconsax.edit,
              size: 20,
            )),
        PopupMenuButton<int>(
            icon: const Icon(Iconsax.document_forward, size: 20),
            initialValue: 1,
            // Callback that sets the selected popup menu item.
            onSelected: (int num) async {
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
        if (scripts[index].type == "image")
          IconButton(
              onPressed: () async {
                try {
                  await saveImageFromUrl(scripts[index].image!.uri);
                  Get.snackbar(_i18n.translate("success"),
                      _i18n.translate("saved_success"),
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: APP_SUCCESS,
                      colorText: Colors.black);
                } catch (err) {
                  Get.snackbar(
                    _i18n.translate("error"),
                    err.toString(),
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: APP_ERROR,
                  );
                }
              },
              icon: const Icon(
                Iconsax.direct_inbox,
                size: 20,
              )),
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
          _bubbleOrNot(
              layout == Layout.COMIC
                  ? SizedBox(
                      width: size.width,
                      child: TextBorder(
                          text: scripts[index].text ?? "",
                          size: 20,
                          textAlign: scripts[index].textAlign))
                  : Text(
                      scripts[index].text ?? "",
                      textAlign: scripts[index].textAlign,
                      style: TextStyle(
                          color:
                              layout == Layout.CONVO ? Colors.black : textColor,
                          fontSize: layout == Layout.COMIC ? 20 : 16),
                    ),
              size,
              alignment),
          lay,
          icons,
        ]);
      case "image":
        AspectRatioImage adjImage = AspectRatioImage(
            imageWidth: scripts[index].image!.width.toDouble(),
            imageHeight: scripts[index].image!.height.toDouble(),
            imageUrl: scripts[index].image!.uri);
        AspectRatioImage modifiedImage = adjImage.displayScript(size);

        return Column(crossAxisAlignment: alignment, children: <Widget>[
          _bubbleOrNot(
              StoryCover(
                photoUrl: modifiedImage.imageUrl,
                title: story.title,
                width: modifiedImage.imageWidth,
                height: modifiedImage.imageHeight,
              ),
              size,
              alignment),
          lay,
          icons,
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
              " ${_i18n.translate("creative_mix_move_page")} ${page.pageNum.toString()}"),
        );
      }
      return PopupMenuItem<int>(
        value: null,
        child: Row(
          children: [
            const Icon(Iconsax.arrow_right_3),
            Text(" ${_i18n.translate("creative_mix_on_current_page")}")
          ],
        ),
      );
    }).toList();
    pagesMenu.add(PopupMenuItem<int>(
        value: story.pages!.length,
        child: Row(
          children: [
            const Icon(Iconsax.add),
            Text(" ${_i18n.translate("creative_mix_add_page")}")
          ],
        )));
    return pagesMenu;
  }

  /// select layouy format. Three choices.
  void _showLayOutSelection() {
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
                Get.back();
              },
            ));
      },
    ).whenComplete(() {
      _updateBackground();
    });
  }

  void _aiImage() async {
    // double height = MediaQuery.of(context).size.height;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: MODAL_HEIGHT_LARGE_FACTOR,
            child: ImageGenerator(
              story: story,
              onSelection: (value) async {
                if (value.isBackground == true) {
                  setState(() {
                    urlPreview = value.galleryUrl;
                    attachmentPreview = null;
                  });
                  _updateBackground();
                } else {
                  await _saveOrUploadTextImg(value);
                }
                Get.back();
              },
            ));
      },
    );
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
  void _addEditText({int? index, AddEditTextCharacter? newContent}) async {
    try {
      if (index == null) {
        await _saveOrUploadTextImg(newContent!);
      } else {
        ScriptImage? uploadedByte;
        if (newContent?.imageBytes != null) {
          Map<String, dynamic> upload =
              await _uploadBytes(newContent!.imageBytes!);
          uploadedByte = ScriptImage(
              size: upload['size'],
              height: upload['height'],
              width: upload['width'],
              uri: upload['uri']);
        }
        String newText = newContent?.text ?? "";
        Script newScript = scripts[index].copyWith(
            text: newText,
            image: uploadedByte,
            type: uploadedByte != null ? 'image' : 'text',
            characterId: newContent?.characterId,
            textAlign: newContent?.textAlign ?? TextAlign.left);

        await _scriptApi.updateScript(script: newScript);

        setState(() {
          scripts[index] = newScript;
        });
      }

      widget.onUpdateSeq(scripts);
      Get.snackbar(_i18n.translate("saved_success"),
          _i18n.translate("creative_mix_save_text"),
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
          reason: 'Unable to save add/edit text in bits ', fatal: true);
    } finally {
      _pr.hide();
    }
  }

  /// save any images texts.
  Future<Script> _saveOrUploadTextImg(AddEditTextCharacter content) async {
    late Script newScript;
    if (content.text != "") {
      StoryPages pages = await _scriptApi.addScriptToStory(
          character: UserModel().user.username,
          characterId: UserModel().user.userId,
          type: "text",
          storyId: story.storyId,
          text: content.text,
          textAlign: content.textAlign ?? TextAlign.left,
          pageNum: widget.pageIndex + 1);
      newScript = pages.scripts![0];
    }
    if (content.attachmentPreview != null) {
      String uploadImage = await uploadFile(
          file: content.attachmentPreview!,
          category: UPLOAD_PATH_SCRIPT_IMAGE,
          categoryId: createUUID());
      var bytes = content.attachmentPreview!.readAsBytesSync();
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
      newScript = pages.scripts![0];
    }

    if (content.imageBytes != null) {
      Map<String, dynamic> uploadedBytes =
          await _uploadBytes(content.imageBytes!);

      StoryPages pages = await _scriptApi.addScriptToStory(
          character: UserModel().user.username,
          characterId: UserModel().user.userId,
          type: "image",
          storyId: story.storyId,
          image: uploadedBytes,
          pageNum: widget.pageIndex + 1);
      newScript = pages.scripts![0];
    }

    if (content.galleryUrl != null) {
      StoryPages pages = await _scriptApi.addScriptToStory(
          character: UserModel().user.username,
          characterId: UserModel().user.userId,
          type: "image",
          storyId: story.storyId,
          image: {
            "size": 9800,
            "height": 516,
            "width": 516, //@todo
            "uri": content.galleryUrl,
            "manual": true
          },
          pageNum: widget.pageIndex + 1);
      newScript = pages.scripts![0];
    }
    setState(() {
      scripts = [...scripts, newScript];
    });
    widget.onUpdateSeq(scripts);
    return newScript;
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
      try {
        await _scriptApi.deleteScript(script: scripts[index]);
      } catch (err, s) {
        await FirebaseCrashlytics.instance.recordError(err, s,
            reason: 'Unable to delete message in delete bits', fatal: true);
      }

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
          reason: 'Unable to delete message in edit bits state', fatal: false);
    }
  }

  /// update background images on the page.
  void _updateBackground() async {
    final storyApi = StoryApi();
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

    await storyApi.updateStory(story: updateStory);
    setState(() {
      story = updateStory;
    });
  }

  void _editPageText({int? index}) async {
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        barrierColor: Colors.black.withOpacity(_alphaValue),
        builder: (context) {
          return FractionallySizedBox(
              heightFactor: MODAL_HEIGHT_LARGE_FACTOR,
              child: AddEditTextWidget(
                  script: index != null ? scripts[index] : null,
                  onTextComplete: (content) =>
                      _addEditText(newContent: content, index: index)));
        });
  }

  /// edit background image of the page.
  void _editPageImage() async {
    await showModalBottomSheet(
        context: context,
        barrierColor: Colors.black.withOpacity(_alphaValue),
        builder: (context) => FractionallySizedBox(
              heightFactor: MODAL_HEIGHT_SMALL_FACTOR,
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

  /// upload bytes to storage.
  Future<Map<String, dynamic>> _uploadBytes(Uint8List bytes) async {
    String uploadImage = await uploadBytesFile(
      uint8arr: bytes,
      category: UPLOAD_PATH_SCRIPT_IMAGE,
      categoryId: createUUID(),
    );

    ui.Codec codec = await ui.instantiateImageCodec(bytes);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return {
      "size": bytes.lengthInBytes,
      "height": frameInfo.image.height,
      "width": frameInfo.image.width,
      "uri": uploadImage,
      "manual": true
    };
  }
}
