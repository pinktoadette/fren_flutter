import 'package:get/get.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/story_cover.dart';

class StoryInfo extends StatefulWidget {
  const StoryInfo({Key? key}) : super(key: key);

  @override
  _StoryInfoState createState() => _StoryInfoState();
}

class _StoryInfoState extends State<StoryInfo> {
  List<dynamic> contributors = [];
  late AppLocalizations _i18n;
  final _storyboardApi = StoryboardApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    Storyboard storyboard = storyboardController.currentStoryboard;
    setState(() {
      storyboard = storyboard;
    });
    super.initState();
    _fetchContributors();
  }

  _fetchContributors() async {
    Storyboard storyboard = storyboardController.currentStoryboard;

    List<dynamic> contribute = await _storyboardApi.getContributors(
        storyboardId: storyboard.storyboardId);
    setState(() {
      contributors = contribute;
    });
  }

  @override
  Widget build(BuildContext context) {
    Story story = storyboardController.currentStory;
    Size size = MediaQuery.of(context).size;
    _i18n = AppLocalizations.of(context);

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
          Text(
            story.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Row(children: [
            Text(
              "${_i18n.translate("story_contributors")}: ",
              style: Theme.of(context).textTheme.labelSmall,
            ),
            ...contributors.map((contribute) => Text(
                "${contribute['character']} ",
                style: Theme.of(context).textTheme.labelSmall))
          ]),
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
