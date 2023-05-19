import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:onboarding/onboarding.dart';

// Story book Onboarding swipe -> child : story_widget
class StoryItemWidget extends StatefulWidget {
  Story story;
  StoryItemWidget({Key? key, required this.story}) : super(key: key);

  @override
  _StoryItemWidgetState createState() => _StoryItemWidgetState();
}

class _StoryItemWidgetState extends State<StoryItemWidget> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  List<PageModel>? pageList;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    double storyCoverWidth = 120;
    double padding = 15;
    double playWidth =
        widget.story.status == StoryStatus.PUBLISHED ? PLAY_BUTTON_WIDTH : 0;

    return Card(
      elevation: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: InkWell(
                onTap: () async {},
                child: StoryCover(
                    width: storyCoverWidth,
                    photoUrl: widget.story.photoUrl ?? "",
                    title: widget.story.title)),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(
                onTap: () async {},
                child: SizedBox(
                    width:
                        width - (storyCoverWidth + playWidth + padding * 3.2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.story.title,
                            style: Theme.of(context).textTheme.labelMedium),
                        Text(widget.story.subtitle,
                            style: Theme.of(context).textTheme.displaySmall),
                      ],
                    )))
          ])
        ],
      ),
    );
  }
}
