import 'dart:async';

import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/screens/home_screen.dart';
import 'package:machi_app/widgets/animations/fireworks.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:get/get.dart';

class PublishStory extends StatefulWidget {
  final Storyboard story;
  const PublishStory({Key? key, required this.story}) : super(key: key);

  @override
  _PublishStoryState createState() => _PublishStoryState();
}

class _PublishStoryState extends State<PublishStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final _storyApi = StoryApi();
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void initState() {
    _publishStory();

    super.initState();
  }

  void _publishStory() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _storyApi.publishStory(widget.story.storyboardId);

      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
      _goToNextStep(3);
    } catch (err) {
      Get.snackbar(
          _i18n.translate("error"), _i18n.translate("an_error_has_occurred"),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: APP_ERROR);
      _goToNextStep(1);
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
                      Padding(
                          padding: const EdgeInsets.only(bottom: 50),
                          child: FireworksAnimation()),
                    Frankloader(),
                  ],
                ),
                if (_isLoading == true)
                  Text(_i18n.translate("story_publishing")),
                if (_isSuccess == true) Text(_i18n.translate("story_success")),
              ],
            )));
  }
}
