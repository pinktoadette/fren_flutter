import 'dart:async';

import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/screens/home_screen.dart';
import 'package:fren_app/widgets/animations/fireworks.dart';
import 'package:fren_app/widgets/animations/loader.dart';
import 'package:get/get.dart';

class PublishStory extends StatefulWidget {
  const PublishStory({Key? key}) : super(key: key);

  @override
  _PublishStoryState createState() => _PublishStoryState();
}

class _PublishStoryState extends State<PublishStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  late Timer timer;

  @override
  void initState() {
    timer = Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
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
                Text(_i18n.translate("story_success"))
              ],
            )));
  }
}
