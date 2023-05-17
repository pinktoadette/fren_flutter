import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/datas/timeline.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/audio/mini_play_control.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/view_storyboard.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:machi_app/widgets/timeline/timeline_header.dart';

class TimelineRowWidget extends StatefulWidget {
  final Storyboard item;
  const TimelineRowWidget({Key? key, required this.item}) : super(key: key);

  @override
  _TimelineRowWidgetState createState() => _TimelineRowWidgetState();
}

class _TimelineRowWidgetState extends State<TimelineRowWidget> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  late AppLocalizations _i18n;
  final _storyboardApi = StoryboardApi();
  final _timelineApi = TimelineApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;

    return Card(
        elevation: 1,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: InkWell(
                    onTap: () async {
                      _onStoryClick();
                    },
                    child: StoryCover(
                        photoUrl: widget.item.photoUrl,
                        title: widget.item.title))),
            SizedBox(
                width: width - 190,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TimelineHeader(
                        showAvatar: true,
                        showName: true,
                        user: widget.item.createdBy),
                    InkWell(
                      onTap: () async {
                        _onStoryClick();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.item.category,
                              style: Theme.of(context).textTheme.labelMedium),
                          Text(
                            widget.item.title,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.item.summary ??
                                "No summary tkhse mlbm ekfbm apebn peabms;dlfbmsdl;fkb dlfknb sonb eobh aehbpeoibj aifjb odfbjsodfib oidfb jsodib ob sodgbn sbons ;odfbn ;i s;in ;;dnb;sn",
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LikeButton(
                  isLiked: widget.item.mylikes == 1 ? true : false,
                  onTap: (value) async {
                    await _onLikePressed(widget.item, !value);
                    return !value;
                  },
                  bubblesColor: BubblesColor(
                    dotPrimaryColor: APP_LIKE_COLOR,
                    dotSecondaryColor: Theme.of(context).primaryColor,
                  ),
                  likeBuilder: (bool isLiked) {
                    return Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? APP_LIKE_COLOR : Colors.grey,
                    );
                  },
                  likeCount: widget.item.likes,
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    Storyboard story = await _storyboardApi
                        .getStoryboardById(widget.item.storyboardId);
                    storyboardController.currentStory = story;
                  },
                  child: MiniAudioWidget(post: widget.item),
                ),
              ],
            )
          ],
        ));
  }

  Future<void> _onStoryClick() async {
    Storyboard story =
        await _storyboardApi.getStoryboardById(widget.item.storyboardId);
    storyboardController.currentStory = story;
    Get.to(() => ViewStory());
  }

  Future<String> _onLikePressed(Storyboard item, bool value) async {
    return await _timelineApi.likeStoryMachi(
        "storyboard", item.storyboardId, value == true ? 1 : 0);
  }
}
