import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/storyboard/story/story_header.dart';

/// Need to call pages since storyboard
/// did not query this in order to increase speed
class StoryPageView extends StatefulWidget {
  final Story story;
  const StoryPageView({Key? key, required this.story}) : super(key: key);

  @override
  _StoryPageViewState createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  late AppLocalizations _i18n;
  double itemHeight = 120;
  final _storyApi = StoryApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  Story? story;

  @override
  void initState() {
    _getStoryContent();
    super.initState();
  }

  void _getStoryContent() async {
    try {
      Story details = await _storyApi.getMyStories(widget.story.storyId);
      setState(() {
        story = details;
      });
    } catch (error) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double headerHeight = 170;
    if (story == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text(_i18n.translate("story_collection")),
          ),
          body: NoData(text: _i18n.translate("loading")));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(_i18n.translate("story_collection")),
        ),
        body: Column(
          children: [
            StoryHeaderWidget(story: story!),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: story!.pages!.map((e) {
                    return Container(
                        height: height - headerHeight,
                        padding: const EdgeInsets.all(2),
                        width: width * 0.9,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Card(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: e.scripts!.map((script) {
                                    return Text(
                                      script.text ?? "",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    );
                                  }).toList()),
                            ),
                          ),
                        ));
                  }).toList(),
                )),
          ],
        ));
  }
}
