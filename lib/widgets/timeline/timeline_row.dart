import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/set_room_bot.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/bot.dart';
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
  final _botApi = BotApi();
  final _storyApi = StoryApi();
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
                    Storyboard story =
                        await _storyApi.getStoryById(widget.item.storyboardId);
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
    Storyboard story = await _storyApi.getStoryById(widget.item.storyboardId);
    storyboardController.currentStory = story;
    Get.to(() => ViewStory());
  }

  Future<String> _onLikePressed(Storyboard item, bool value) async {
    return await _timelineApi.likeStoryMachi(
        "storyboard", item.storyboardId, value == true ? 1 : 0);
  }

  Widget _showTitle(Timeline post) {
    double width = MediaQuery.of(context).size.width;
    double itemHeight = 150;
    dynamic firstText;
    dynamic firstImage;

    for (var sub in post.subText) {
      if (sub["messages"]["type"] == "text" && firstText == null) {
        firstText = sub["messages"];
      }
      if (sub["messages"]["type"] == "image" && firstImage == null) {
        firstImage = sub["messages"];
      }
    }
    double imageHeight = width * 0.3 - 50;

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: firstImage != null ? width * 0.65 - 30 : width - 50,
                height: itemHeight - 50,
                child: Text(firstText["text"],
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
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
                            firstImage["image"]["uri"],
                            width: width * 0.3,
                            fit: BoxFit.cover,
                          ),
                        ))
                  ],
                )
            ],
          ),
        ]);
  }
}
