import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/bot_api.dart';
import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/api/machi/timeline_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/controller/set_room_bot.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/datas/timeline.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/helpers/truncate_text.dart';
import 'package:fren_app/screens/storyboard/storyboard_view.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/image/image_rounded.dart';
import 'package:fren_app/widgets/timeline/timeline_header.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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
  ChatController chatController = Get.find(tag: 'chatroom');

  static const _pageSize = 20;

  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);

  Future<void> _getTimeline(int pageKey) async {
    try {
      List<Timeline> newItems =
          await _timelineApi.getTimeline(_pageSize, pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey as int);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _getTimeline(pageKey);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double itemHeight = 200;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
        height: height - 290,
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: PagedListView<int, dynamic>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<dynamic>(
              animateTransitions: true,
              transitionDuration: const Duration(milliseconds: 500),
              itemBuilder: (context, item, index) {
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
                }
                return ListTile(
                    minLeadingWidth: 15,
                    isThreeLine: true,
                    title: TimelineHeader(showAvatar: true, user: item.user),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _showTitle(item),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            LikeButton(
                              isLiked: item.mylikes == 1 ? true : false,
                              onTap: (value) async {
                                await _onLikePressed(item, !value);
                                return !value;
                              },
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
                              likeCount: item.likes,
                            )
                          ],
                        )
                      ],
                    ));
              }),
        ));
  }

  Future<String> _onLikePressed(Timeline item, bool value) async {
    return await _timelineApi.likeStoryMachi(
        item.postType, item.id, value == true ? 1 : 0);
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
            Flexible(
                child: Text(
              post.text,
              style: Theme.of(context).textTheme.headlineSmall,
              overflow: TextOverflow.ellipsis,
            )),
          ]),
          subtitle: Text(
            truncateText(50, post.subText),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          trailing: post.mymachi == false
              ? ElevatedButton(
                  onPressed: () async {
                    Bot bot = await _botApi.getBot(botId: post.id);
                    _showBotInfo(bot);
                  },
                  child: Text(_i18n.translate("get")),
                )
              : OutlinedButton(
                  onPressed: () async {
                    Bot bot = await _botApi.getBot(botId: post.id);
                    SetCurrentRoom().setRoom(bot);
                  },
                  child: Text(_i18n.translate("chat")),
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
