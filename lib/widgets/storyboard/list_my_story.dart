import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/no_data.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:fren_app/widgets/storyboard/edit_storyboard.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class MyStories extends StatefulWidget {
  final types.Message? message;
  const MyStories({Key? key, this.message}) : super(key: key);

  @override
  _MyStoriesState createState() => _MyStoriesState();
}

class _MyStoriesState extends State<MyStories> {
  late AppLocalizations _i18n;
  final _storyApi = StoryApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return RefreshIndicator(
        onRefresh: () async {
          // Refresh Functionality
          await _storyApi.getMyStories();
        },
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: storyboardController.stories.isEmpty
                ? Align(
                    alignment: Alignment.center,
                    child: Text(
                      _i18n.translate("story_nothing"),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Obx(
                    () => GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 1,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20),
                        itemCount: storyboardController.stories.length,
                        itemBuilder: (BuildContext ctx, index) {
                          Storyboard story =
                              storyboardController.stories[index];
                          if (story.title.isEmpty) {
                            return NoData(
                                text: _i18n.translate("story_nothing"));
                          }
                          return InkWell(
                              onTap: () {
                                widget.message != null
                                    ? _addMessage(index, story)
                                    : Get.to(EditStory(
                                        story: story,
                                        storyIdx: index,
                                      ));
                              },
                              child: Card(
                                  child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(story.title,
                                          style: const TextStyle(fontSize: 14)),
                                      if (story.scene != null)
                                        _showMessage(context, story.scene!),
                                      const Spacer(),
                                      Text(
                                        "Items: ${story.scene!.length}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      )
                                    ]),
                              )));
                        }),
                  )));
  }

  void _addMessage(int index, Storyboard story) async {
    try {
      await _storyApi.addStory(index, widget.message!.id, story.storyboardId);
      Get.snackbar(
        _i18n.translate("story_added"),
        _i18n.translate("story_added_info"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_SUCCESS,
      );
    } catch (err) {
      debugPrint(err.toString());
      Get.snackbar(
        'Error',
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }

  Widget _showMessage(BuildContext context, List<dynamic> message) {
    // ~ two columns for image to fit into this square
    double square = MediaQuery.of(context).size.width / 2;

    if (message.isEmpty) {
      return const SizedBox.shrink();
    }
    final firstMessage = message[0].messages;

    switch (firstMessage.type) {
      case (types.MessageType.text):
        return Flexible(
            child: Text(
          firstMessage.text,
          style: const TextStyle(fontSize: 10),
        ));
      case (types.MessageType.image):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: square * 0.5,
              child: Image.network(
                firstMessage.uri,
                width: square,
                fit: BoxFit.cover,
              ),
            )
          ],
        );
      default:
        return const Icon(Iconsax.activity);
    }
  }
}
