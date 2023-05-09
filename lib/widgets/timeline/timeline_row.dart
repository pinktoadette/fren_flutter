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
import 'package:machi_app/widgets/storyboard/view_storyboard.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';

class TimelineRowWidget extends StatefulWidget {
  final Timeline item;
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

    dynamic firstText;
    dynamic firstImage;

    for (var sub in widget.item.subText) {
      if (sub["messages"]["type"] == "text" && firstText == null) {
        firstText = sub["messages"];
      }
      if (sub["messages"]["type"] == "image" && firstImage == null) {
        firstImage = sub["messages"];
      }
    }

    return Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          decoration: firstImage != null
              ? BoxDecoration(
                  image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.7), BlendMode.darken),
                  image: NetworkImage(firstImage["image"]["uri"]),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ))
              : BoxDecoration(color: Colors.black.withOpacity(0.8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Row(
                  children: [
                    Text(
                      widget.item.text,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    LikeButton(
                      isLiked: widget.item.mylikes == 1 ? true : false,
                      onTap: (value) async {
                        await _onLikePressed(widget.item, !value);
                        return !value;
                      },
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: APP_ACCENT_COLOR,
                        dotSecondaryColor: Theme.of(context).primaryColor,
                      ),
                      likeBuilder: (bool isLiked) {
                        return Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? APP_ACCENT_COLOR : Colors.grey,
                        );
                      },
                      likeCount: widget.item.likes,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
                child: InkWell(
                  onTap: () async {
                    if (widget.item.postType == "board") {
                      Storyboard story =
                          await _storyApi.getStoryById(widget.item.id);
                      storyboardController.currentStory = story;
                      Get.to(() => ViewStory());
                    }
                  },
                  child: _showTitle(widget.item),
                ),
              ),
              InkWell(
                onTap: () async {
                  Storyboard story =
                      await _storyApi.getStoryById(widget.item.id);
                  storyboardController.currentStory = story;
                },
                child: MiniAudioWidget(post: widget.item),
              ),
            ],
          ),
        ));
  }

  Future<String> _onLikePressed(Timeline item, bool value) async {
    return await _timelineApi.likeStoryMachi(
        item.postType, item.id, value == true ? 1 : 0);
  }

  Widget _showTitle(Timeline post) {
    double width = MediaQuery.of(context).size.width;
    double itemHeight = 150;

    switch (post.postType) {
      /// Note: this is the similar to as list_my_board: _showMessage()
      case "board":
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14)),
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

      case "machi":
        // Note: same as row_Bot_info but this class is different
        double widthPercent = 0.2;

        return SizedBox(
          width: width,
          child: InkWell(
              onTap: () async {
                Bot bot = await _botApi.getBot(botId: post.id);
                SetCurrentRoom().setNewBotRoom(bot, true);
              },
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: width * widthPercent,
                          width: (width * (1 - widthPercent)) - 42,
                          child: Text(
                            post.subText,
                            style: Theme.of(context).textTheme.displaySmall,
                          ))
                    ],
                  )
                ],
              )),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
