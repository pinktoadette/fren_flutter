import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/audio/mini_play_control.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:onboarding/onboarding.dart';

// Story book Onboarding swipe -> child : story_widget
class StoryItemWidget extends StatefulWidget {
  const StoryItemWidget({Key? key}) : super(key: key);

  @override
  _StoryItemWidgetState createState() => _StoryItemWidgetState();
}

class _StoryItemWidgetState extends State<StoryItemWidget> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  late Story story;
  List<PageModel>? pageList;
  late int index;

  @override
  void initState() {
    _getThisStoryPages();
    super.initState();
    index = 0;
  }

  void _getThisStoryPages() {
    story = storyboardController.currentStory;
    // List<PageModel>? text = story.pages!.map((page) {
    //   String? text = page.scripts?.map((e) => e.text).join("");
    //   return PageModel(widget: Text(text ?? "Nothing here"));
    // }).toList();
    setState(() {
      story = story;
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double imageWidth = 80;

    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: story.pages!.map((e) {
            return Container(
                height: height - 80,
                padding: const EdgeInsets.all(2),
                width: width * 0.9,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: e.scripts!.map((script) {
                            return Text(
                              script.text ?? "",
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          }).toList()),
                    ),
                  ),
                ));
          }).toList(),
        ));
  }
}
