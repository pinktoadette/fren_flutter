import 'package:get/get.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/widgets/story_cover.dart';

class StoryInfo extends StatelessWidget {
  const StoryInfo({super.key});

  @override
  Widget build(BuildContext context) {
    StoryboardController storyboardController = Get.find(tag: 'storyboard');
    Story story = storyboardController.currentStory;
    Size size = MediaQuery.of(context).size;

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
            story.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
              child: StoryCover(
            width: size.width * 0.75,
            height: size.width * 0.75,
            photoUrl: story.photoUrl ?? "",
            title: story.title,
          )),
          const SizedBox(
            height: 20,
          ),
          Text(story.summary ?? ""),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
        ],
      ),
    );
  }
}
