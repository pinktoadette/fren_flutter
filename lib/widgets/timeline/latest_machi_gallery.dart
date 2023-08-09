import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/controller/set_room_bot.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/gallery.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/helpers/navigation_helper.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/subscribe/subscribe_card.dart';

class LatestMachiWidget extends StatefulWidget {
  const LatestMachiWidget({super.key});

  @override
  _LatestMachiWidgetState createState() => _LatestMachiWidgetState();
}

class _LatestMachiWidgetState extends State<LatestMachiWidget> {
  UserController userController = Get.find(tag: 'user');
  ChatController chatController = Get.find(tag: 'chatroom');
  SubscribeController subscriptionController = Get.find(tag: 'subscribe');
  final _timelineApi = TimelineApi();
  late AppLocalizations _i18n;

  Map<String, dynamic> items = {'machi': <Bot>[], 'gallery': <Gallery>[]};
  @override
  void initState() {
    super.initState();
    _getHomePage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getHomePage() async {
    Map<String, dynamic> homepageItems = items;
    if (userController.user == null) {
      homepageItems = await _timelineApi.getPublicHomepage();
    } else {
      homepageItems = await _timelineApi.getHomepage();
    }
    setState(() {
      items = homepageItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _i18n = AppLocalizations.of(context);
    if (items['machi'].isEmpty) {
      return const Frankloader();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InlineAdaptiveAds(),
        const SizedBox(height: 20),

        Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            _i18n.translate("latest_machi_for_you"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...items['machi'].map((bot) {
                    return InkWell(
                        onTap: () {
                          NavigationHelper.handleGoToPageOrLogin(
                            context: context,
                            userController: userController,
                            navigateAction: () {
                              SetCurrentRoom().setNewBotRoom(bot, true);
                            },
                          );
                        },
                        child: SizedBox(
                            width: size.width / 3.5,
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: bot.profilePhoto != ""
                                      ? imageCacheWrapper(bot.profilePhoto!)
                                      : null,
                                ),
                                Text(
                                  bot.name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  bot.category,
                                  style: Theme.of(context).textTheme.labelSmall,
                                )
                              ],
                            )));
                  })
                ])),
        if (userController.user != null)
          subscriptionController.customer == null
              ? const SizedBox.shrink()
              : subscriptionController.customer!.allPurchaseDates.isEmpty
                  ? const SubscriptionCard()
                  : const SizedBox.shrink(),
        const SizedBox(height: 20),
        Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            _i18n.translate("latest_gallery"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        // 3x3 grid of image placeholders
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
          ),
          itemCount: items['gallery'].length,
          itemBuilder: (context, index) {
            Gallery gallery = items['gallery'][index];
            return Container(
              color: Colors.grey,
              child: StoryCover(
                  radius: 0,
                  photoUrl: gallery.photoUrl,
                  title: gallery.caption),
            );
          },
        ),
        const InlineAdaptiveAds(),
      ],
    );
  }
}
