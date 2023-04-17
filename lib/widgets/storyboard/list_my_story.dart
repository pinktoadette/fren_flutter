import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/storyboard/edit_storyboard.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class MyStories extends StatefulWidget {
  final bool isAdd;
  const MyStories({Key? key, required this.isAdd}) : super(key: key);

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
        onRefresh: () {
          // Refresh Functionality
          return _storyApi.getMyStories();
          ;
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
                                childAspectRatio: 4 / 3,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20),
                        itemCount: storyboardController.stories.length,
                        itemBuilder: (BuildContext ctx, index) {
                          Storyboard story =
                              storyboardController.stories[index];
                          return Card(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              alignment: Alignment.topLeft,
                              child: InkWell(
                                onTap: () {
                                  widget.isAdd
                                      ? _addMessage(story)
                                      : Get.to(EditStory(story: story));
                                },
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(story.title,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black)),
                                      _showMessage(story.messages),
                                    ]),
                              ),
                            ),
                          );
                        }),
                  )));
  }

  void _addMessage(Storyboard story) {}

  Widget _showMessage(List<dynamic> message) {
    if (message.isEmpty) {
      return const SizedBox.shrink();
    }
    final firstMessage = message[0];
    print(firstMessage);
    switch (firstMessage.type) {
      case (types.MessageType.text):
        return Flexible(
            child: Text(
          firstMessage.text,
          style: const TextStyle(fontSize: 10, color: Colors.black),
        ));
      case (types.MessageType.image):
        return Container(
            constraints: const BoxConstraints.expand(),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(firstMessage.image.uri),
                  fit: BoxFit.cover),
            ));
      default:
        return const Icon(Iconsax.activity);
    }
  }
}
