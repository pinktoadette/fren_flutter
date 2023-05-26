import 'package:iconsax/iconsax.dart';
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
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Iconsax.trash,
                  size: 18,
                ))
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
                          text: _i18n.translate("storycast_board_nothing"));
                    }
                    Story story =
                        storyboardController.currentStoryboard.story![index];

                    return StoryItemWidget(
                        story: story, message: widget.message);
                  }),
            ),
          ],
        ));
  }
}
