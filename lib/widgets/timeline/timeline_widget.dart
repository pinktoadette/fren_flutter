import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/bot_api.dart';
import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/api/machi/timeline.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/datas/timeline.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/helpers/truncate_text.dart';
import 'package:fren_app/screens/storyboard/storyboard_view.dart';
import 'package:fren_app/widgets/avatar_initials.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/image/image_rounded.dart';
import 'package:fren_app/widgets/no_data.dart';
import 'package:fren_app/widgets/timeline/timeline_header.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:like_button/like_button.dart';

class TimelineWidget extends StatefulWidget {
  const TimelineWidget({Key? key}) : super(key: key);

  @override
  _TimelineWidgetState createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  final _botApi = BotApi();
  final _storyApi = StoryApi();
  final _timelineApi = TimelineApi();
  late AppLocalizations _i18n;

  /// timeline items
  int _offset = 0;
  List<Timeline> _timelines = [];

  Future<void> _getTimeline() async {
    int limit = 30;
    List<Timeline> timeline = await _timelineApi.getTimeline(limit, _offset);
    setState(() {
      _timelines = timeline;
      _offset = _offset + 1;
    });
  }

  @override
  void initState() {
    _getTimeline();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double itemHeight = 200;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (_timelines.isEmpty) {
      /// No match
      return NoData(text: _i18n.translate("no_match"));
    } else {
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              separatorBuilder: (context, index) {
                if ((index + 1) % 5 == 0) {
                  return Container(
                    height: itemHeight,
                    color: Theme.of(context).colorScheme.background,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Container(
                        height: 150,
                        width: width,
                        color: Colors.yellow,
                        child: const Text('ad placeholder'),
                      ),
                    ),
                  );
                } else {
                  return const Divider();
                }
              },
              itemCount: _timelines.length,
              itemBuilder: (context, index) => ListTile(
                    minLeadingWidth: 15,
                    isThreeLine: true,
                    title: TimelineHeader(
                        showAvatar: true, user: _timelines[index].user),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _showTitle(_timelines[index]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            LikeButton(
                              bubblesColor: BubblesColor(
                                dotPrimaryColor: APP_ACCENT_COLOR,
                                dotSecondaryColor:
                                    Theme.of(context).primaryColor,
                              ),
                              likeBuilder: (bool isLiked) {
                                return Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      isLiked ? APP_ACCENT_COLOR : Colors.grey,
                                );
                              },
                              likeCount: 10,
                            )
                          ],
                        )
                      ],
                    ),
                  )));
    }
  }

  Widget _showTitle(Timeline post) {
    double width = MediaQuery.of(context).size.width;
    switch (post.postType) {
      case "board":
        if (post.subText.isNotEmpty) {
          Widget hasMore = const SizedBox.shrink();
          if (post.subText.length > 1) {
            hasMore = Text(_i18n.translate("story_read_more"));
          }

          return InkWell(
              onTap: () async {
                Storyboard story = await _storyApi.getStoryById(post.id);
                Get.to(StoryboardView(
                  story: story,
                ));
              },
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.text,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                        width: width,
                        child: post.subText[0]["messages"]["type"] == "image"
                            ? RoundedImage(
                                width: width * 0.15,
                                height: width * 0.15,
                                icon: const Icon(Iconsax.box_add),
                                photoUrl: post.subText[0]["messages"]["image"]
                                    ["uri"])
                            : Text(
                                post.subText[0]["messages"]["text"],
                              )),
                    hasMore,
                  ]));
        }
        return const SizedBox.shrink();
      case "machi":
        return ListTile(
          dense: true,
          minLeadingWidth: width * 0.15,
          isThreeLine: true,
          leading: RoundedImage(
              width: width * 0.15,
              height: width * 0.15,
              icon: const Icon(Iconsax.box_add),
              photoUrl: post.photoUrl ?? ""),
          title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text(
              post.text,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ]),
          subtitle: Text(
            truncateText(50, post.subText),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          trailing: ElevatedButton(
            onPressed: () async {
              Bot bot = await _botApi.getBot(botId: post.id);
              _showBotInfo(bot);
            },
            child: Text(_i18n.translate("get")),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _showBotInfo(Bot bot) {
    double height = MediaQuery.of(context).size.height;

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: max(height, 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              BotProfileCard(
                bot: bot,
                showPurchase: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}
