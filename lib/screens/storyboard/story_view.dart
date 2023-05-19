import 'package:dotted_border/dotted_border.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/screens/storyboard/add_new_story.dart';
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
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: widget.message == null
              ? Text(_i18n.translate("storyboard"))
              : Text(_i18n.translate("add_message_collection")),
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              storyboardController.clearStory();
              Get.back();
            },
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StoryboardHeaderWidget(
              storyboard: storyboardController.currentStoryboard,
            ),
            if (widget.message == null)
              Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: DottedBorder(
                    dashPattern: const [4],
                    strokeWidth: 2,
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    padding: const EdgeInsets.all(6),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: SizedBox(
                          height: 100,
                          width: width,
                          child: TextButton.icon(
                              onPressed: () {
                                Get.to(() => AddNewStory(
                                    storyboard: storyboardController
                                        .currentStoryboard));
                              },
                              icon: const Icon(Iconsax.add),
                              label: Text(
                                  _i18n.translate("add_story_collection")))),
                    ),
                  )),
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
