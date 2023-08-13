import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/screens/home_screen.dart';
import 'package:machi_app/widgets/animations/fireworks.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:get/get.dart';

class PublishStory extends StatefulWidget {
  final Story story;
  const PublishStory({Key? key, required this.story}) : super(key: key);

  @override
  State<PublishStory> createState() => _PublishStoryState();
}

class _PublishStoryState extends State<PublishStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  TimelineController timelineController = Get.find(tag: 'timeline');
  final _storyApi = StoryApi();
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _publishStory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _publishStory() async {
    if (!mounted) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
        _isSuccess = false;
      });
      await _storyApi.publishStory(widget.story.storyId);

      /// update storyboard controller
      Story updateStory = widget.story.copyWith(status: StoryStatus.PUBLISHED);
      storyboardController.updateStory(story: updateStory);

      /// in current story. We know current storyboard
      /// add to timeline
      Storyboard newStoryboard =
          storyboardController.findStoryboardByStory(widget.story);
      timelineController.insertPublishStoryboard(newStoryboard);

      _goToNextStep(3);
    } catch (err, s) {
      Get.snackbar(
          _i18n.translate("error"), _i18n.translate("an_error_has_occurred"),
          snackPosition: SnackPosition.TOP, backgroundColor: APP_ERROR);
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Publishing story error occurred. Check if its published.',
          fatal: true);
      _goToNextStep(1);
    } finally {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  void _goToNextStep(int second) {
    Timer(Duration(seconds: second), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    if (_isSuccess == true)
                      const Padding(
                          padding: EdgeInsets.only(bottom: 50),
                          child: FireworksAnimation()),
                    if (_isLoading == false) const Frankloader(),
                  ],
                ),
                if (_isLoading == true)
                  Text(_i18n.translate("creative_mix_publishing")),
                if (_isSuccess == true)
                  Text(_i18n.translate("creative_mix_publish_success")),
              ],
            )));
  }
}
