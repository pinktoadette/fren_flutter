import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/gallery.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/subscribe/subscribe_card.dart';
import 'package:machi_app/widgets/timeline/timeline_widget.dart';

class SuggestionWidget extends StatefulWidget {
  const SuggestionWidget({super.key});

  @override
  _SuggestionWidgetState createState() => _SuggestionWidgetState();
}

class _SuggestionWidgetState extends State<SuggestionWidget> {
  ChatController chatController = Get.find(tag: 'chatroom');
  SubscribeController subscriptionController = Get.find(tag: 'subscribe');
  final _timelineApi = TimelineApi();
  late AppLocalizations _i18n;

  Map<String, dynamic> items = {
    'machi': <Bot>[],
    'gallery': <Gallery>[],
    'story': <Storyboard>[],
  };
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
    Map<String, dynamic> homepageItems = await _timelineApi.getHomepage();
    setState(() {
      items = homepageItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _i18n = AppLocalizations.of(context);

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const InlineAdaptiveAds(),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.bottomLeft,
              child: Text(_i18n.translate("latest_machi_for_you")),
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...items['machi'].map((bot) {
                    return Row(
                      children: [
                        SizedBox(
                          width: size.width / 3,
                          child: Column(
                            children: [
                              StoryCover(
                                  photoUrl: bot.profilePhoto ?? "",
                                  title: bot.name),
                              Text(
                                bot.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                bot.category,
                                style: Theme.of(context).textTheme.labelSmall,
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  })
                ]),

            subscriptionController.customer == null
                ? const SizedBox.shrink()
                : subscriptionController.customer!.allPurchaseDates.isEmpty
                    ? const SubscriptionCard()
                    : const SizedBox.shrink(),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(_i18n.translate("latest_gallery")),
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

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.bottomLeft,
              child: Text(_i18n.translate("latest_story")),
            ),
            const TimelineWidget()
          ],
        ));
  }
}
