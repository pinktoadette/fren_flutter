import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/helpers/navigation_helper.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/bot/bot_profile.dart';
import 'package:machi_app/widgets/bot/explore_bot.dart';
import 'package:machi_app/widgets/bot/prompt_create.dart';
import 'package:machi_app/widgets/storyboard/new_story_card.dart';
import 'package:machi_app/widgets/subscribe/subscribe_card.dart';

class LatestMachiWidget extends StatefulWidget {
  const LatestMachiWidget({super.key});

  @override
  State<LatestMachiWidget> createState() => _LatestMachiWidgetState();
}

class _LatestMachiWidgetState extends State<LatestMachiWidget> {
  UserController userController = Get.find(tag: 'user');
  TimelineController timelineController = Get.find(tag: 'timeline');
  late AppLocalizations _i18n;

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
    if (!mounted) {
      return;
    }
    try {
      bool isLoggedIn = userController.user == null ? false : true;
      await timelineController.fetchHomepageItems(isLoggedIn);
    } catch (err, stack) {
      Get.snackbar(
        _i18n.translate("Error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Error getting homepage items ${err.toString()}',
          fatal: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;

    return Obx(() => timelineController.machiList.isEmpty
        ? const Frankloader()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InlineAdaptiveAds(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      _i18n.translate("latest_machi_for_you"),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.only(right: 10),
                    child: TextButton(
                        onPressed: () {
                          NavigationHelper.handleGoToPageOrLogin(
                            context: context,
                            userController: userController,
                            navigateAction: () async {
                              Get.to(() => const ExploreMachi());
                            },
                          );
                        },
                        child: Text(_i18n.translate("see_all"),
                            style: Theme.of(context).textTheme.bodyMedium)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _addBot(size),
                        ...timelineController.machiList.map((bot) {
                          return SizedBox(
                              width: size.width / 4.5,
                              child: _showBotAvatar(bot: bot, size: size));
                        })
                      ])),
              const SizedBox(height: 20),
              const CreateStoryCard(),
              if (userController.user != null) _showSubscriptionCard(),
              const SizedBox(height: 20),
            ],
          ));
  }

  Widget _showSubscriptionCard() {
    SubscribeController subscriptionController = Get.find(tag: 'subscribe');
    return subscriptionController.customer!.allPurchaseDates.isEmpty
        ? const SubscriptionCard()
        : const SizedBox.shrink();
  }

  Widget _addBot(Size size) {
    return InkWell(
        onTap: () {
          showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (context) => FractionallySizedBox(
                  heightFactor: MODAL_HEIGHT_LARGE_FACTOR,
                  child: DraggableScrollableSheet(
                    snap: true,
                    initialChildSize: 1,
                    minChildSize: 1,
                    builder: (context, scrollController) =>
                        SingleChildScrollView(
                      controller: scrollController,
                      child: const CreateMachiWidget(),
                    ),
                  )));
        },
        child: SizedBox(
            width: size.width / 4.5,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: size.width / 4.5,
                    height: size.width / 4.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: APP_ACCENT_COLOR,
                        width: 2.0, // Adjust the border width as needed
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.add, color: APP_ACCENT_COLOR),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    _i18n.translate("add"),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(_i18n.translate("create_me"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10))
                ])));
  }

  Widget _showBotAvatar({required Bot bot, required Size size}) {
    return InkWell(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return FractionallySizedBox(
                  heightFactor: 400 / size.height,
                  widthFactor: 1,
                  child: BotProfileCard(
                    bot: bot,
                    showChatbuttom: true,
                  ));
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              foregroundImage: bot.profilePhoto == ''
                  ? null
                  : ImageCacheWrapper(bot.profilePhoto!),
              backgroundColor: APP_INVERSE_PRIMARY_COLOR,
              child: (bot.profilePhoto == '')
                  ? Center(
                      child: Text(bot.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              color: APP_PRIMARY_COLOR, fontSize: 18)),
                    )
                  : null,
            ),
            Text(
              bot.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(bot.category,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10))
          ],
        ));
  }
}
