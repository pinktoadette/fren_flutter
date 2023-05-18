import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/view_storyboard.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:onboarding/onboarding.dart';

class StoryItemWidget extends StatefulWidget {
  final Story item;
  const StoryItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  _StoryItemWidgettState createState() => _StoryItemWidgettState();
}

class _StoryItemWidgettState extends State<StoryItemWidget> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  late AppLocalizations _i18n;
  final _storyboardApi = StoryboardApi();
  final _timelineApi = TimelineApi();

  @override
  void initState() {
    super.initState();
  }

  void _getScript() {}

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    double storyCoverWidth = 120;
    double padding = 15;
    double playWidth =
        widget.item.status == StoryStatus.PUBLISHED ? PLAY_BUTTON_WIDTH : 0;
    return Onboarding(
      startPageIndex: 0,
      pages: [],
    );
  }

  PageModel _storyText() {
    return PageModel(
        widget: Container(
      child: Text(widget.item.title),
    ));
  }

  Future<void> _onStoryClick() async {
    Storyboard story =
        await _storyboardApi.getStoryboardById(widget.item.storyId);
    storyboardController.currentStoryboard = story;
    Get.to(() => ViewStoryboard());
  }

  Future<String> _onLikePressed(Storyboard item, bool value) async {
    return await _timelineApi.likeStoryMachi(
        "story", item.storyboardId, value == true ? 1 : 0);
  }
}
