import 'package:iconsax/iconsax.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/screens/storyboard/page_view.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:onboarding/onboarding.dart';

class StoryItemWidget extends StatefulWidget {
  final Story story;
  const StoryItemWidget({Key? key, required this.story}) : super(key: key);

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

    return InkWell(
        onTap: () {
          Get.to(() => StoryPageView(story: widget.story));
        },
        child: Card(
          elevation: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(padding),
                child: StoryCover(
                    width: storyCoverWidth,
                    photoUrl: widget.story.photoUrl ?? "",
                    title: widget.story.title),
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: width -
                            (storyCoverWidth + playWidth + padding * 3.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.story.title,
                                style: Theme.of(context).textTheme.labelMedium),
                            Text(widget.story.subtitle,
                                style:
                                    Theme.of(context).textTheme.displaySmall),
                            Text(widget.story.summary ?? "",
                                style:
                                    Theme.of(context).textTheme.displaySmall),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: null,
                                  icon: const Icon(Iconsax.menu_1),
                                  label: Text(
                                      "${widget.story.pages?.length ?? 0} pages",
                                      style: const TextStyle(fontSize: 12)),
                                ),
                                Text(
                                    "update ${formatDate(widget.story.updatedAt!)}",
                                    style: const TextStyle(fontSize: 10))
                              ],
                            )
                          ],
                        ))
                  ])
            ],
          ),
        ));
  }
}
