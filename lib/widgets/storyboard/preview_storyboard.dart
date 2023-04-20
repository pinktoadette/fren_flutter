import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/storyboard/story_view.dart';
import 'package:get/get.dart';

class PreviewStory extends StatefulWidget {
  final Storyboard story;
  const PreviewStory({Key? key, required this.story}) : super(key: key);

  @override
  _PreviewStoryState createState() => _PreviewStoryState();
}

class _PreviewStoryState extends State<PreviewStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            _i18n.translate("storyboard_preview"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
            physics: const ScrollPhysics(),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.story.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.left,
                  ),
                  StoryView(story: widget.story)
                ])));
  }
}
