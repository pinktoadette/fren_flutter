import 'dart:math';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/no_data.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/story/story_item_widget.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/storyboard/story/storyboard_header.dart';

class StoriesView extends StatefulWidget {
  const StoriesView({Key? key}) : super(key: key);

  @override
  _StoriesViewState createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView> {
  late AppLocalizations _i18n;
  double itemHeight = 120;
  final _storyboardApi = StoryboardApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(_i18n.translate("storyboard")),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StoryboardHeaderWidget(
              storyboard: storyboardController.currentStoryboard,
            ),
            Obx(
              () => ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount:
                      storyboardController.currentStoryboard.story!.length,
                  itemBuilder: (BuildContext ctx, index) {
                    if (storyboardController.currentStoryboard.story!.isEmpty) {
                      return NoData(
                          text: _i18n.translate("storycast_board_nothing"));
                    }
                    Story story =
                        storyboardController.currentStoryboard.story![index];

                    return StoryItemWidget(story: story);
                  }),
            ),
          ],
        ));
  }

  Widget _showHeader() {
    Storyboard storyboard = storyboardController.currentStoryboard;
    double width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(20),
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StoryCover(
              width: width * 0.7,
              height: width * 0.7,
              photoUrl: storyboard.photoUrl ?? "",
              title: storyboard.title),
          const SizedBox(
            height: 10,
          ),
          Text(storyboard.category),
          Text(storyboard.title,
              style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}
