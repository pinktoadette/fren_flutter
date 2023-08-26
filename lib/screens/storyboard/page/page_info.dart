import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/common/avatar_initials.dart';
import 'package:machi_app/widgets/like_widget.dart';

class StoryPageInfoWidget extends StatefulWidget {
  const StoryPageInfoWidget({super.key});

  @override
  State<StoryPageInfoWidget> createState() => _StoryPageInfoWidgetState();
}

class _StoryPageInfoWidgetState extends State<StoryPageInfoWidget> {
  final StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final TimelineController timelineController = Get.find(tag: 'timeline');
  final _timelineApi = TimelineApi();
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
        width: 80,
        height: size.height / 2,
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Padding(
                  padding: const EdgeInsets.only(right: 0, bottom: 10),
                  child: AvatarInitials(
                      radius: 25,
                      userId:
                          storyboardController.currentStory.createdBy.userId,
                      photoUrl:
                          storyboardController.currentStory.createdBy.photoUrl,
                      username: storyboardController
                          .currentStory.createdBy.username)),
              Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Obx(() => LikeItemWidget(
                      isVertical: true,
                      onLike: (val) {
                        _onLikePressed(storyboardController.currentStory, val);
                      },
                      fontColor: APP_INVERSE_PRIMARY_COLOR,
                      size: 20,
                      buttonSize: 24,
                      likes: timelineController.currentStory.likes ?? 0,
                      mylikes: timelineController.currentStory.mylikes ?? 0))),
              Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      const Icon(
                        Iconsax.message,
                        size: 24,
                        color: APP_INVERSE_PRIMARY_COLOR,
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      Obx(() => Text(
                            timelineController.currentStory.commentCount
                                .toString(),
                            style: const TextStyle(
                                fontSize: 12, color: APP_INVERSE_PRIMARY_COLOR),
                          ))
                    ],
                  )),
              Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: IconButton(
                    onPressed: () => {_copyLink(context)},
                    icon: const Icon(Icons.share),
                    iconSize: 16,
                    color: APP_INVERSE_PRIMARY_COLOR,
                  )),
            ]),
          ],
        ));
  }

  Future<void> _onLikePressed(Story item, bool value) async {
    try {
      String response = await _timelineApi.likeStoryMachi(
          "story", item.storyId, value == true ? 1 : 0);
      if (response == "OK") {
        Story update = item.copyWith(
            mylikes: value == true ? 1 : 0,
            likes:
                value == true ? (item.likes! + 1) : max(0, (item.likes! - 1)));
        timelineController.updateStoryboard(
            storyboard: storyboardController.currentStoryboard,
            updateStory: update);
      }
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );

      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Cannot like storyboard item', fatal: false);
    }
  }

  void _copyLink(BuildContext context) {
    String textToCopy =
        "${APP_WEBSITE}post/${storyboardController.currentStory.storyId.substring(0, 5)}-${storyboardController.currentStory.slug}";
    Clipboard.setData(ClipboardData(text: textToCopy));
    Get.snackbar("Link", 'Copied to clipboard: $textToCopy',
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_TERTIARY,
        colorText: Colors.white);
  }
}
