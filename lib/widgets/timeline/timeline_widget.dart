import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/bot_api.dart';
import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/api/machi/timeline.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/screens/storyboard/storyboard_view.dart';
import 'package:fren_app/widgets/avatar_initials.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/no_data.dart';
import 'package:fren_app/widgets/timeline/timeline_header.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';

class Timeline extends StatefulWidget {
  const Timeline({Key? key}) : super(key: key);

  @override
  _TimelineWidget createState() => _TimelineWidget();
}

class _TimelineWidget extends State<Timeline> {
  final _botApi = BotApi();
  final _storyApi = StoryApi();
  final _timelineApi = TimelineApi();
  late AppLocalizations _i18n;

  /// timeline items
  int _offset = 0;
  List _timelines = [];

  Future<void> _getTimeline() async {
    int limit = 30;
    List timeline = await _timelineApi.getTimeline(limit, _offset);
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
                    leading: AvatarInitials(
                        photoUrl: _timelines[index]["createdBy"]["photoUrl"],
                        username: _timelines[index]["createdBy"]["username"]),
                    title: TimelineHeader(user: _timelines[index]["createdBy"]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _timelines[index]["text"],
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.left,
                        ),
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

  Widget _showTitle(dynamic post) {
    double width = MediaQuery.of(context).size.width;
    switch (post["postType"]) {
      case "board":
        if (post["subText"].isNotEmpty) {
          Widget hasMore = const SizedBox.shrink();
          if (post["subText"].length > 1) {
            hasMore = Text(_i18n.translate("story_read_more"));
          }

          return InkWell(
              onTap: () async {
                Storyboard story = await _storyApi.getStoryById(post["id"]);
                Get.to(StoryboardView(
                  story: story,
                ));
              },
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: width - 100,
                        child: post["subText"][0]["messages"]["type"] == "image"
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  post["subText"][0]["messages"]["image"]
                                      ["uri"],
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                post["subText"][0]["messages"]["text"],
                              )),
                    hasMore,
                  ]));
        }
        return const SizedBox.shrink();
      case "machi":
        return InkWell(
            // onTap: () async {
            //   Bot bot = await _botApi.getBot(botId: )
            //   _showBotInfo(bot);
            // },
            child: Text(post["subText"]));
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
