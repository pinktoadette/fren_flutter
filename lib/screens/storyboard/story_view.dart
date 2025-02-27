import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/storyboard/story/add_new_story.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/storyboard/story/story_item_widget.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/storyboard/story/storyboard_header.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

/// StoryboardItemWidget -> StoriesView (List of stories / Add ) -> StoryItemWidget -> PageView
/// message input is when the user wants to add the message to the collection.
class StoriesView extends StatefulWidget {
  final types.Message? message;

  const StoriesView({Key? key, this.message}) : super(key: key);
  @override
  State<StoriesView> createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView> {
  late AppLocalizations _i18n;
  final _storyApi = StoryApi();
  double itemHeight = 120;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: widget.message == null
                ? Text(
                    _i18n.translate("creative_mix_collection"),
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : Text(
                    _i18n.translate("add_message_collection"),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
            leading: BackButton(
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                storyboardController.clearStory();
                Navigator.pop(context);
              },
            ),
            leadingWidth: 50,
            centerTitle: false,
            actions: _listOfActions()),
        body: SingleChildScrollView(
            physics: const ScrollPhysics(),
            child: Column(children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StoryboardHeaderWidget(),
                  const Divider(
                    color: Colors.white12,
                  ),
                  if (widget.message != null)
                    Align(
                        alignment: Alignment.center,
                        child: ElevatedButton.icon(
                          icon: isLoading == true
                              ? loadingButton(size: 16)
                              : const Icon(Iconsax.add),
                          label: Text(
                            _i18n.translate("add_to_new_creative_mix"),
                          ),
                          onPressed: () async {
                            _addMessage();
                          },
                        )),
                  Obx(
                    () => ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: storyboardController
                            .currentStoryboard.story!.length,
                        itemBuilder: (BuildContext ctx, index) {
                          if (storyboardController
                              .currentStoryboard.story!.isEmpty) {
                            return NoData(
                                text: _i18n.translate("creative_mix_nothing"));
                          }
                          Story story = storyboardController
                              .currentStoryboard.story![index];
                          bool isOwnerUnpub = (story.createdBy.userId ==
                                  UserModel().user.userId) &&
                              (story.status != StoryStatus.PUBLISHED);
                          return Dismissible(
                              key: Key(story.storyId),
                              direction: isOwnerUnpub
                                  ? DismissDirection.endToStart
                                  : DismissDirection.none,
                              confirmDismiss:
                                  (DismissDirection direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        _i18n.translate("DELETE"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      content: Text(_i18n
                                          .translate("story_delete_confirm")),
                                      actions: <Widget>[
                                        OutlinedButton(
                                            onPressed: () => {
                                                  Navigator.of(context)
                                                      .pop(false),
                                                },
                                            child: Text(
                                                _i18n.translate("CANCEL"))),
                                        const SizedBox(
                                          width: 50,
                                        ),
                                        ElevatedButton(
                                            onPressed: () => {
                                                  _onDelete(story),
                                                },
                                            child: Text(
                                                _i18n.translate("DELETE"))),
                                      ],
                                    );
                                  },
                                );
                              },
                              background: Container(
                                  color: APP_ERROR,
                                  child: const Icon(Iconsax.trash)),
                              child: StoryItemWidget(
                                  story: story, message: widget.message));
                        }),
                  ),
                ],
              )
            ])));
  }

  List<Widget> _listOfActions() {
    if ((storyboardController.currentStoryboard.createdBy.userId !=
        UserModel().user.userId)) {
      return [const SizedBox.shrink()];
    }
    return [
      if (widget.message == null)
        TextButton.icon(
            onPressed: () {
              Get.to(() => const AddNewStory());
            },
            icon: const Icon(Iconsax.add),
            label: Text(
              _i18n.translate("create_mix_new_collection"),
              style: Theme.of(context).textTheme.labelSmall,
            )),
    ];
  }

  void _onDelete(Story story) async {
    try {
      await _storyApi.deletStory(story);
      Get.back(result: true);

      Get.snackbar(
          _i18n.translate("success"), _i18n.translate("story_success_delete"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS,
          colorText: Colors.black);
    } catch (err) {
      Get.snackbar(
        _i18n.translate("DELETE"),
        _i18n.translate("story_delete_error"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
    }
  }

  void _addMessage() async {
    setState(() {
      isLoading = true;
    });
    try {
      dynamic message = widget.message;
      if (message.type == types.MessageType.text) {
        await _storyApi.createStory(
          storyboardId: storyboardController.currentStoryboard.storyboardId,
          title: "",
          photoUrl: "",
          text: message.text,
        );
      }
      if (message.type == types.MessageType.image) {
        await _storyApi.createStory(
            storyboardId: storyboardController.currentStoryboard.storyboardId,
            title: "",
            photoUrl: message.uri,
            text: "");
      }
      Get.back(result: true);
      Get.snackbar(_i18n.translate("success"),
          _i18n.translate("creative_mix_edit_added_messages"),
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
          reason: 'Error adding message in story view', fatal: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
