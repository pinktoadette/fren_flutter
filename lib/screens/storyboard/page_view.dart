import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/storyboard/my_edit/edit_storyboard.dart';
import 'package:machi_app/widgets/storyboard/story/story_header.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Need to call pages since storyboard
/// did not query this in order to increase speed
class StoryPageView extends StatefulWidget {
  final Story story;
  const StoryPageView({Key? key, required this.story}) : super(key: key);

  @override
  _StoryPageViewState createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  final controller = PageController(viewportFraction: 0.8, keepPage: true);

  late AppLocalizations _i18n;
  double itemHeight = 120;
  final _storyApi = StoryApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  Story? story;
  var pages = [];

  @override
  void initState() {
    _getStoryContent();
    super.initState();
  }

  void _getStoryContent() async {
    try {
      Story details = await _storyApi.getMyStories(widget.story.storyId);
      pages = _getPages(details);

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
              _i18n.translate("storybits"),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          body: NoData(text: _i18n.translate("loading")));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            _i18n.translate("storybits"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            if (story?.status != StoryStatus.PUBLISHED)
              IconButton(
                  onPressed: () {
                    // Get.to(() => const EditStory());
                  },
                  icon: const Icon(
                    Iconsax.edit,
                    size: 20,
                  )),
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
                  itemCount: pages.length,
                  itemBuilder: (_, index) {
                    return pages[index];
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

  List _getPages(Story story) {
    return story.pages!.map((e) {
      return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: const EdgeInsets.only(left: 0, right: 40),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: e.scripts!.map((script) {
                  return Text(
                    script.text ?? "",
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }).toList()),
          ));
    }).toList();
  }
}
