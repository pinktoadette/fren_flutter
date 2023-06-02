import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/storyboard/story/add_new_story.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/storyboard/story/story_item_widget.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/storyboard/story/storyboard_header.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

/// StoryboardItemWidget -> StoriesView (List of stories / Add ) -> StoryItemWidget -> PageView
/// message input is when the user wants to add the message to the collection.
/// user cannot create a new collection here
class StoriesView extends StatefulWidget {
  /// passed from chat messages to be added to story collection
  /// This is a very deep pass.
  /// Chat -> storyboard_item -> story_view -> story_item
  final types.Message? message;

  const StoriesView({Key? key, this.message}) : super(key: key);
  @override
  _StoriesViewState createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView> {
  late AppLocalizations _i18n;
  final _storyApi = StoryApi();
  double itemHeight = 120;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          title: widget.message == null
              ? Text(
                  _i18n.translate("story_collection"),
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
          actions: [
            if (widget.message == null)
              TextButton.icon(
                  onPressed: () {
                    Get.to(() => const AddNewStory());
                  },
                  icon: const Icon(Iconsax.add),
                  label: Text(
                    _i18n.translate("new_story_collection"),
                    style: Theme.of(context).textTheme.labelSmall,
                  )),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StoryboardHeaderWidget(),
            Obx(
              () => ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount:
                      storyboardController.currentStoryboard.story!.length,
                  itemBuilder: (BuildContext ctx, index) {
                    if (storyboardController.currentStoryboard.story!.isEmpty) {
                      return NoData(
                          text: _i18n.translate("storyboard_nothing"));
                    }
                    Story story =
                        storyboardController.currentStoryboard.story![index];

                    return Dismissible(
                        key: Key(story.storyId),
                        direction: DismissDirection.endToStart,
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
                                    _i18n.translate("story_confirm_delete")),
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
                                            _onDelete(story),
                                          },
                                      child: Text(_i18n.translate("DELETE"))),
                                ],
                              );
                            },
                          );
                        },
                        background: Container(
                            color: APP_ERROR, child: const Icon(Iconsax.trash)),
                        child: StoryItemWidget(
                            story: story, message: widget.message));
                  }),
            ),
          ],
        ));
  }

  void _onDelete(Story story) async {
    try {
      await _storyApi.deletStory(story);
      Navigator.of(context).pop(true);
      Get.snackbar(
        _i18n.translate("DELETE"),
        _i18n.translate("story_success_delete"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_SUCCESS,
      );
    } catch (err) {
      Get.snackbar(
        _i18n.translate("DELETE"),
        _i18n.translate("story_delete_error"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }
}
