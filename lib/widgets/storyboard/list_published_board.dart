import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/widgets/storyboard/view_storyboard.dart';
import 'package:get/get.dart';

class ListMyPublishedStories extends StatefulWidget {
  final types.Message? message;
  const ListMyPublishedStories({Key? key, this.message}) : super(key: key);

  @override
  _MyPublishedStoriesState createState() => _MyPublishedStoriesState();
}

class _MyPublishedStoriesState extends State<ListMyPublishedStories> {
  late AppLocalizations _i18n;
  double itemHeight = 150;
  final _storyApi = StoryApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    storyboardController.getPublished();
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
        child: storyboardController.published.isEmpty
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
                    itemCount: storyboardController.published.length,
                    itemBuilder: (BuildContext ctx, index) {
                      Storyboard story = storyboardController.published[index];
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
                              child: Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(5),
                            height: itemHeight,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Text(story.status.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall),
                                      const Text(" ∙ "),
                                      Text(formatDate(story.createdAt),
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

  void _onStoryClick(int index, Storyboard story) {
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
