import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/storyboard/view_storyboard.dart';
import 'package:fren_app/widgets/storyboard/story_view.dart';
import 'package:get/get.dart';

class MyStories extends StatefulWidget {
  final types.Message? message;
  const MyStories({Key? key, this.message}) : super(key: key);

  @override
  _MyStoriesState createState() => _MyStoriesState();
}

class _MyStoriesState extends State<MyStories> {
  late AppLocalizations _i18n;
  double itemHeight = 150;
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
        child: storyboardController.stories.isEmpty
            ? Align(
                alignment: Alignment.center,
                child: Text(
                  _i18n.translate("story_nothing"),
                  textAlign: TextAlign.center,
                ),
              )
            : Obx(
                () => ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: storyboardController.stories.length,
                    itemBuilder: (BuildContext ctx, index) {
                      Storyboard story = storyboardController.stories[index];
                      if (story.title.isEmpty) {
                        return Align(
                          alignment: Alignment.center,
                          child: Text(
                            _i18n.translate("story_nothing"),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return InkWell(
                          onTap: () {
                            _onStoryClick(index, story);
                          },
                          child: Card(
                              color: story.status == StoryStatus.PUBLISHED
                                  ? APP_ACCENT_COLOR
                                  : Theme.of(context).colorScheme.background,
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(5),
                                height: itemHeight,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(story.title,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall),
                                          const Spacer(),
                                          if (story.status ==
                                              StoryStatus.PUBLISHED)
                                            Text(story.status.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall)
                                        ],
                                      ),
                                      if (story.scene != null)
                                        _showMessage(context, story.scene!),
                                    ]),
                              )));
                    }),
              ));
  }

  void _addMessage(int index, Storyboard story) async {
    try {
      await _storyApi.addStory(index, widget.message!.id, story.storyboardId);
      Navigator.of(context).pop();
      Get.snackbar(
        _i18n.translate("story_added"),
        _i18n.translate("story_added_info"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_SUCCESS,
      );
    } catch (err) {
      debugPrint(err.toString());
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }

  void _onStoryClick(int index, Storyboard story) {
    if (story.status == StoryStatus.PUBLISHED) {
      showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (context) => FractionallySizedBox(
              heightFactor: 0.9,
              child: DraggableScrollableSheet(
                snap: true,
                initialChildSize: 1,
                minChildSize: 0.75,
                builder: (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  physics: const ScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        story.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.left,
                      ),
                      StoryViewDetails(story: story),
                    ],
                  ),
                ),
              )));
    } else {
      widget.message != null
          ? _addMessage(index, story)
          : _setCurrentStory(story);
    }
  }

  void _setCurrentStory(Storyboard story) {
    storyboardController.currentStory = story;
    Get.to(() => ViewStory());
  }

  Widget _showMessage(BuildContext context, List<Scene> message) {
    if (message.isEmpty) {
      return const SizedBox.shrink();
    }
    final firstText = message.firstWhereOrNull(
        (ele) => ele.messages.type == types.MessageType.text) as dynamic;
    final firstImage = message.firstWhereOrNull(
        (ele) => ele.messages.type == types.MessageType.image) as dynamic;
    double width = MediaQuery.of(context).size.width;
    double imageHeight = width * 0.3 - 20;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: firstImage != null ? width * 0.65 - 20 : width - 40,
          height: itemHeight - 50,
          child: Text(
            firstText.messages.text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (firstImage != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                  height: imageHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      firstImage.messages.uri,
                      width: width * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ))
            ],
          )
      ],
    );
  }
}
