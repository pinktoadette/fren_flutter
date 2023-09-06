import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';

class StoryInfo extends StatefulWidget {
  const StoryInfo({Key? key}) : super(key: key);

  @override
  State<StoryInfo> createState() => _StoryInfoState();
}

class _StoryInfoState extends State<StoryInfo> {
  List<dynamic> contributors = [];
  final _cancelToken = CancelToken();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    Storyboard storyboard = storyboardController.currentStoryboard;
    setState(() {
      storyboard = storyboard;
    });
    super.initState();
  }

  @override
  void dispose() {
    _cancelToken.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Semantics(
                  label: storyboardController.currentStory.title,
                  child: Text(
                    storyboardController.currentStory.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  )),
              const SizedBox(
                height: 20,
              ),
              Semantics(
                label: storyboardController.currentStory.summary ?? "",
                child: Text(storyboardController.currentStory.summary ?? ""),
              ),
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom,
              ),
            ],
          ),
        ));
  }
}
