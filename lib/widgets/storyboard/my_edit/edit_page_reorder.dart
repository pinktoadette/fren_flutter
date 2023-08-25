import 'dart:io';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/script_api.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/datas/add_edit_text.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/dialogs/progress_dialog.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/create_uuid.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/helpers/downloader.dart';
import 'package:machi_app/helpers/image_aspect_ratio.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/helpers/text_link_preview.dart';
import 'package:machi_app/helpers/truncate_text.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/widgets/ads/reward_ads.dart';
import 'package:machi_app/widgets/common/chat_bubble_container.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/bottom_sheets/add_edit_text.dart';
import 'package:machi_app/widgets/storyboard/my_edit/add_ai_image.dart';
import 'package:machi_app/widgets/storyboard/my_edit/edit_page_background.dart';
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';
import 'package:machi_app/widgets/subscribe/subscription_product.dart';

// ignore: must_be_immutable
class EditPageReorder extends StatefulWidget {
  Story story;
  final List<Script> scriptList;
  final int pageIndex;
  final Function(List<Script> data) onUpdateSeq;
  final Function(dynamic data) onMoveInsertPages;
  final Function(Layout data) onLayoutSelection;
  Layout? layout;

  EditPageReorder(
      {Key? key,
      required this.story,
      required this.scriptList,
      required this.onMoveInsertPages,
      required this.onUpdateSeq,
      required this.onLayoutSelection,
      this.pageIndex = 0,
      this.layout})
      : super(key: key);

  @override
  State<EditPageReorder> createState() => _EditPageReorderState();
}

class _EditPageReorderState extends State<EditPageReorder> {
  /// api calls here are related to delete/move script.
  /// adding, editing of scripts are saved when user swipes to next page and change is detected.
  final _scriptApi = ScriptApi();

  /// Subscribe controller to update token counter if user uses AI image.
  final SubscribeController subscribeController = Get.find(tag: 'subscribe');

  /// Update storyboard and story in the controller.
  final StoryboardController storyboardController = Get.find(tag: 'storyboard');

  /// Individual scripts in the story.
  late List<Script> scripts;

  /// The story of the content.
  late Story story;

  /// Language localization.
  late AppLocalizations _i18n;
  late ProgressDialog _pr;

  /// Media size screen to determine width of script.
  late Size size;

  /// Updates to changes of layout on selection.
  Layout? layout;

  /// Attach user's image from devide.
  File? attachmentPreview;

  /// Image url from user's gallery.
  String? urlPreview;

  /// Thumbnail for large background images when user attaches image or gallery url.
  String? thumbnail;

  /// Adjusting background alpha color to see text.
  double _alphaValue = 0.25;

  @override
  void initState() {
    super.initState();
    setState(() {
      scripts = widget.scriptList;
      story = storyboardController.currentStory;
      layout = widget.layout;
      if (story.pages?.isNotEmpty == true) {
        urlPreview = story.pages![widget.pageIndex].backgroundImageUrl;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
    size = MediaQuery.of(context).size;
    _pr = ProgressDialog(context, isDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
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
                          _onPageEditText();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.image),
                        onPressed: () {
                          /// check if there's a subscription
                          _onGenerateClick();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.gallery),
                        onPressed: () {
                          _onPageImageEdit();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.grid_3),
                        onPressed: () {
                          _onShowLayoutSelection();
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
    bool hasBackground =
        !isEmptyString(story.pages![widget.pageIndex].backgroundImageUrl) ||
            !isEmptyString(urlPreview) ||
            !isEmptyString(attachmentPreview?.path ?? "");
    double alphaValue = hasBackground ? _alphaValue : 0;

    return Container(
        margin: const EdgeInsets.only(bottom: 100),
        constraints: BoxConstraints(minHeight: size.width),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          image: DecorationImage(
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(alphaValue), BlendMode.darken),
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
              _onPageEditText(index: index);
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

    // Showing user's name on convo layout
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

    // Scaffold text and image structure.
    switch (scripts[index].type) {
      case "text":
        String? background = _selectFirstImageNotNull();

        return Column(crossAxisAlignment: alignment, children: [
          _bubbleOrNot(
              textLinkPreview(
                  useBorder:
                      !isEmptyString(background) && layout != Layout.CONVO,
                  width: layout != Layout.CONVO ? size.width : null,
                  text: scripts[index].text ?? "",
                  textAlign: scripts[index].textAlign ?? TextAlign.left,
                  style: TextStyle(
                      color: layout == Layout.CONVO ? Colors.black : null,
                      fontSize: layout != Layout.COMIC ? 16 : 20)),
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
  void _onShowLayoutSelection() {
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
      _onBackgroundUpdate();
    });
  }

  /// Determine if user has enough tokens to generate images.
  void _onGenerateClick() {
    if (subscribeController.token.netCredits <= 0) {
      showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (context) => Obx(() => FractionallySizedBox(
              heightFactor: subscribeController.token.netCredits > 0
                  ? MODAL_HEIGHT_SMALL_FACTOR
                  : MODAL_HEIGHT_LARGE_FACTOR,
              child: const SubscriptionProduct())));
    } else {
      if (subscribeController.token.netCredits <= 2) {
        _showAlert();
      } else {
        _aiImage();
      }
    }
  }

  /// Show alerts when not enough tokens.
  void _showAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              _i18n.translate("creative_mix_ai_not_enough_tokens"),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            content: SizedBox(
                height: 150,
                child: Column(
                  children: [
                    Text(_i18n.translate("creative_mix_ai_image_credits")),
                    const SizedBox(height: 20),
                    RewardAds(
                      text: _i18n.translate("watch_ads_earn"),
                      onAdStatus: (data) {
                        Get.snackbar(
                            _i18n.translate("success"), "Rewarded $data tokens",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: APP_SUCCESS,
                            colorText: Colors.black);
                      },
                    ),
                  ],
                )),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () =>
                      {Navigator.of(context).pop(false), Get.back()},
                  child: Text(_i18n.translate("OK"))),
            ],
          );
        });
  }

  void _aiImage() {
    Get.to(() => ImageGenerator(
          story: story,
          onError: (errorMessage) {
            Get.snackbar(
              _i18n.translate("error"),
              _i18n.translate(errorMessage),
              snackPosition: SnackPosition.TOP,
              backgroundColor: APP_ERROR,
            );
          },
          onSelection: (value) async {
            if (value.isBackground == true) {
              setState(() {
                urlPreview = value.galleryUrl;
                thumbnail = value.thumbnail;
                attachmentPreview = null;
              });
              _onBackgroundUpdate();
            } else {
              await _addNewTextImage(value);
            }
          },
        ));
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
        await _addNewTextImage(newContent!);
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
        StoryUser createdBy = StoryUser(
            userId: newContent!.characterId,
            photoUrl: "",
            username: newContent.characterName);
        Script newScript = scripts[index].copyWith(
            text: newText,
            image: uploadedByte,
            createdBy: createdBy,
            type: uploadedByte != null ? 'image' : 'text',
            characterId: newContent.characterId,
            textAlign: newContent.textAlign ?? TextAlign.left);

        setState(() {
          scripts[index] = newScript;
        });
        _updateSequence();
      }
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
  Future<Script> _addNewTextImage(AddEditTextCharacter content) async {
    late Script newScript;
    Script newItem = Script.fromJson({
      "character": content.characterName,
      "characterId": content.characterId,
      "textAlign": content.textAlign?.name,
      "storyId": story.storyId,
      "pageNum": widget.pageIndex + 1,
      "createdAt": getDateTimeEpoch(),
      "updatedAt": getDateTimeEpoch(),
    });
    if (content.text != "") {
      newScript = newItem.copyWith(text: content.text, type: "text");
    }
    if (content.attachmentPreview != null) {
      String uploadImage = await uploadFile(
          file: content.attachmentPreview!,
          category: UPLOAD_PATH_SCRIPT_IMAGE,
          categoryId: createUUID());
      var bytes = content.attachmentPreview!.readAsBytesSync();
      var result = await decodeImageFromList(bytes);

      newScript = newItem.copyWith(
          text: content.text,
          type: "image",
          image: ScriptImage(
            size: bytes.length,
            height: result.height.toInt(),
            width: result.width.toInt(),
            uri: uploadImage,
          ));
    }

    if (content.imageBytes != null) {
      Map<String, dynamic> uploadedBytes =
          await _uploadBytes(content.imageBytes!);

      newScript = newItem.copyWith(
          text: content.text,
          type: "image",
          image: ScriptImage(
            size: uploadedBytes['size'],
            height: uploadedBytes['height'],
            width: uploadedBytes['width'],
            uri: uploadedBytes['uri'],
          ));
    }

    if (content.galleryUrl != null) {
      newScript = newItem.copyWith(
          text: content.text,
          type: "image",
          image: ScriptImage(
            size: 9800,
            height: 512,
            width: 512,
            uri: content.galleryUrl!,
          ));
    }

    setState(() {
      scripts = [...scripts, newScript];
    });

    StoryPages pages = await _scriptApi.addScriptToStory(
        type: newScript.type!,
        character: newScript.characterName ?? "",
        text: newScript.text,
        characterId: content.characterId, // ?? @todo should get rid of these
        image: newScript.image != null
            ? {
                "uri": newScript.image!.uri,
                "size": newScript.image!.size,
                "height": newScript.image!.height,
                "width": newScript.image!.width
              }
            : null,
        pageNum: widget.pageIndex + 1,
        storyId: widget.story.storyId);
    storyboardController.addNewScriptToStory(pages);

    return newScript;
  }

  /// updates the sequence of the individual script when dragged/dropped and moved to other pages.
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
      _updateSequence();
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
  void _onBackgroundUpdate() async {
    final storyApi = StoryApi();
    String? url = urlPreview;
    bool hasChanges = false;

    if (attachmentPreview != null) {
      url = await uploadFile(
          file: attachmentPreview!,
          category: UPLOAD_PATH_COLLECTION,
          categoryId: createUUID());
    }

    /// Get the original background
    StoryPages storyPages =
        storyboardController.currentStory.pages![widget.pageIndex];

    /// delete last uploadfile
    if (storyPages.backgroundImageUrl != null &&
        url != null &&
        storyPages.backgroundImageUrl != url) {
      deleteFileByUrl(storyPages.backgroundImageUrl!);
      if (storyPages.thumbnail != null) {
        deleteFileByUrl(storyPages.thumbnail!);
      }
    }

    if (storyPages.backgroundImageUrl != url) {
      ///  reassign new image url
      storyPages.backgroundImageUrl = url;
      storyPages.thumbnail = thumbnail;
      hasChanges = true;
    }
    if (storyPages.backgroundAlpha != _alphaValue) {
      hasChanges = true;
      storyPages.backgroundAlpha = _alphaValue;
    }

    if (hasChanges == true) {
      story.pages![story.pages!.indexWhere(
          (element) => element.pageNum == widget.pageIndex + 1)] = storyPages;

      Story updateStory = story.copyWith(pages: story.pages);
      storyboardController.updateStory(story: updateStory);
      await storyApi.updateStory(story: updateStory);
      setState(() {
        story = updateStory;
      });
    }
  }

  void _onPageEditText({int? index}) async {
    Get.to(() => AddEditTextWidget(
        script: index != null ? scripts[index] : null,
        onTextComplete: (content) =>
            _addEditText(newContent: content, index: index)));
  }

  /// edit background image of the page.
  void _onPageImageEdit() async {
    String? backgroundImage = _selectFirstImageNotNull();
    await showModalBottomSheet(
        context: context,
        barrierColor: Colors.black.withOpacity(_alphaValue),
        builder: (context) => FractionallySizedBox(
              heightFactor: MODAL_HEIGHT_SMALL_FACTOR,
              child: EditPageBackground(
                  passStory: story,
                  alpha: _alphaValue,
                  backgroundImage: backgroundImage,
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
      _onBackgroundUpdate();
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
    };
  }

  /// selects image that is not empty or null
  String? _selectFirstImageNotNull() {
    List<String?> items = [
      urlPreview,
      story.pages?[widget.pageIndex].backgroundImageUrl
    ];

    String? selectedString = items.firstWhere(
        (item) => item != null && item.isNotEmpty,
        orElse: () => null);
    return selectedString;
  }
}
