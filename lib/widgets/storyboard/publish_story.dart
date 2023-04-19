import 'dart:async';

import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/screens/home_screen.dart';
import 'package:fren_app/widgets/animations/fireworks.dart';
import 'package:fren_app/widgets/animations/loader.dart';
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
  bool isLoading = false;
  bool hasError = false;

  @override
  void initState() {
    _publishStory();

    super.initState();
  }

  void _publishStory() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _storyApi.publishStory(widget.story.storyboardId);

      setState(() {
        isLoading = false;
      });
      _goToNextStep();
    } catch (err) {
      debugPrint(err.toString());
      setState(() {
        hasError = true;
      });
      Get.snackbar('Error', _i18n.translate("an_error_has_occurred"),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: APP_ERROR);
      _goToNextStep();
    }
  }

  void _goToNextStep() {
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: height / 3,
                ),
                Stack(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Fireworks()),
                    Frankloader(),
                  ],
                ),
                if (isLoading == true)
                  Text(_i18n.translate("story_publishing")),
                if (hasError == false && isLoading == false)
                  Text(_i18n.translate("story_success")),
              ],
            )));
  }
}
