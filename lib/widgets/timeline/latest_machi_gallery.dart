import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/set_room_bot.dart';
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
import 'package:machi_app/widgets/profile/gallery/gallery_mini.dart';
import 'package:machi_app/widgets/subscribe/subscribe_card.dart';
import 'package:machi_app/widgets/timeline/latest_gallery.dart';

class LatestMachiWidget extends StatefulWidget {
  const LatestMachiWidget({super.key});

  @override
  _LatestMachiWidgetState createState() => _LatestMachiWidgetState();
}

class _LatestMachiWidgetState extends State<LatestMachiWidget> {
  UserController userController = Get.find(tag: 'user');
  SubscribeController subscriptionController = Get.find(tag: 'subscribe');
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
    Size size = MediaQuery.of(context).size;
    _i18n = AppLocalizations.of(context);

    return Obx(() => timelineController.machiList.isEmpty
        ? const Frankloader()
        : Column(
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
              const SizedBox(height: 10),
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...timelineController.machiList.map((bot) {
                          return InkWell(
                              onTap: () {
                                _showBotInfo(bot);
                              },
                              child: SizedBox(
                                  width: size.width / 4.5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: bot.profilePhoto != ""
                                            ? imageCacheWrapper(
                                                bot.profilePhoto!)
                                            : null,
                                      ),
                                      Text(
                                        bot.name,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Text(bot.category,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 10))
                                    ],
                                  )));
                        })
                      ])),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      _i18n.translate("latest_gallery"),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.only(right: 10),
                    child: TextButton(
                        onPressed: () {
                          Get.to(() => const LatestGallery());
                        },
                        child: Text(_i18n.translate("see_all"),
                            style: Theme.of(context).textTheme.bodyMedium)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GalleryWidget(gallery: timelineController.galleryList),
              if (userController.user != null)
                subscriptionController.customer == null
                    ? const SizedBox.shrink()
                    : subscriptionController.customer!.allPurchaseDates.isEmpty
                        ? const SubscriptionCard()
                        : const SizedBox.shrink(),
              const SizedBox(height: 20),
            ],
          ));
  }

  void _showBotInfo(Bot bot) {
    double height = MediaQuery.of(context).size.height;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 400 / height,
            child: Column(children: [
              BotProfileCard(
                bot: bot,
              ),
              TextButton(
                  onPressed: () {
                    NavigationHelper.handleGoToPageOrLogin(
                      context: context,
                      userController: userController,
                      navigateAction: () {
                        SetCurrentRoom().setNewBotRoom(bot, true);
                      },
                    );
                  },
                  child: Text(_i18n.translate("lets_chat")))
            ]));
      },
    );
  }
}
