import 'package:get/get.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/widgets/story_cover.dart';

class StoryboardInfo extends StatelessWidget {
  const StoryboardInfo({super.key});

  @override
  Widget build(BuildContext context) {
    StoryboardController storyboardController = Get.find(tag: 'storyboard');
    Size size = MediaQuery.of(context).size;
    Storyboard storyboard = storyboardController.currentStoryboard;
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            storyboard.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
              child: StoryCover(
            width: size.width * 0.75,
            height: size.width * 0.75,
            photoUrl: storyboard.photoUrl ?? "",
            title: storyboard.title,
          )),
          const SizedBox(
            height: 20,
          ),
          Text(storyboard.summary ?? ""),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
        ],
      ),
    );
  }
}
