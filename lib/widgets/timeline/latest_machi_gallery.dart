import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/set_room_bot.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/datas/gallery.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/helpers/navigation_helper.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/image/image_expand.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/subscribe/subscribe_card.dart';

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
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...timelineController.machiList.map((bot) {
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      Text(
                                        bot.category,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
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
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                children: List.generate(
                  timelineController.galleryList.length,
                  (index) {
                    Gallery gallery = timelineController.galleryList[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the expanded image page
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ExpandedImagePage(gallery: gallery),
                          ),
                        );
                      },
                      child: StoryCover(
                        radius: 0,
                        photoUrl: gallery.photoUrl,
                        title: gallery.caption,
                      ),
                    );
                  },
                ),
              ),
              const InlineAdaptiveAds(),
            ],
          ));
  }
}
