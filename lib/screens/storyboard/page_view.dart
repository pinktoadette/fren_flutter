import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/screens/storyboard/add_new_story.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/image/image_rounded.dart';
import 'package:machi_app/widgets/storyboard/my_edit/edit_story.dart';
import 'package:machi_app/widgets/storyboard/publish_story.dart';
import 'package:machi_app/widgets/storyboard/story/story_header.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Need to call pages since storyboard
/// did not query this in order to increase speed
class StoryPageView extends StatefulWidget {
  final Story story;
  final bool? isPreview;
  const StoryPageView({Key? key, required this.story, this.isPreview = false})
      : super(key: key);

  @override
  _StoryPageViewState createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  final controller = PageController(viewportFraction: 1, keepPage: true);

  late AppLocalizations _i18n;
  double itemHeight = 120;
  final _storyApi = StoryApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  Story? story;
  var pages = [];

  @override
  void initState() {
    super.initState();
    if (widget.isPreview == true) {
      setState(() {
        story = widget.story;
      });
    } else {
      getStoryContent();
    }
  }

  void getStoryContent() async {
    try {
      Story details = await _storyApi.getMyStories(widget.story.storyId);

      storyboardController.setCurrentStory(details);
      setState(() {
        story = details;
      });
    } catch (error) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double headerHeight = 170;
    if (story == null && pages.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isPreview == true
                  ? _i18n.translate("storyboard_preview")
                  : _i18n.translate("story_collection"),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          body: NoData(text: _i18n.translate("loading")));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isPreview == true
                ? _i18n.translate("storyboard_preview")
                : _i18n.translate("story_collection"),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          actions: [
            if (widget.isPreview == false) _unpublishedTools(),
            if (widget.isPreview == true)
              Container(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => PublishStory(story: story!));
                      },
                      child: Text(_i18n.translate("publish"))))
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            StoryHeaderWidget(story: story!),
            SizedBox(
                height: height - headerHeight - 20,
                width: width,
                child: PageView.builder(
                  controller: controller,
                  itemCount: story!.pages!.length,
                  itemBuilder: (_, index) {
                    List<Script>? scripts = story!.pages![index].scripts;
                    return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Card(
                            child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: scripts!.map((script) {
                                if (script.type == "text") {
                                  return Text(
                                    script.text ?? "",
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  );
                                } else if (script.type == "image") {
                                  return RoundedImage(
                                    width: 516,
                                    height: 516,
                                    photoUrl: script.image?.uri ?? "",
                                    icon: const Icon(Iconsax.image),
                                  );
                                }
                                return const SizedBox.shrink();
                              }).toList()),
                        )));
                  },
                )),
            SmoothPageIndicator(
              controller: controller,
              count: story!.pages!.length,
              effect: const ExpandingDotsEffect(
                  dotHeight: 14,
                  dotWidth: 14,
                  // type: WormType.thinUnderground,
                  activeDotColor: APP_ACCENT_COLOR),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        )));
  }

  Widget _unpublishedTools() {
    Storyboard storyboard = storyboardController.currentStoryboard;
    return Row(
      children: [
        if ((story?.status != StoryStatus.PUBLISHED) &
            (storyboard.story!.length == 1))
          TextButton.icon(
              onPressed: () {
                Get.to(() => AddNewStory(
                    storyboard: storyboardController.currentStoryboard));
              },
              icon: const Icon(Iconsax.add),
              label: Text(
                _i18n.translate("new_story_collection"),
                style: Theme.of(context).textTheme.labelSmall,
              )),
        if (story?.status != StoryStatus.PUBLISHED)
          IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPage(
                      passStory: story ?? widget.story,
                    ),
                  ),
                ).then((val) {
                  setState(() {
                    story = val;
                  });
                });
              },
              icon: const Icon(
                Iconsax.edit,
                size: 20,
              ))
      ],
    );
  }
}
