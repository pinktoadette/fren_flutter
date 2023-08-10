import 'package:get/get.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/story_cover.dart';

class StoryboardInfo extends StatefulWidget {
  const StoryboardInfo({Key? key}) : super(key: key);

  @override
  _StoryboardInfoState createState() => _StoryboardInfoState();
}

class _StoryboardInfoState extends State<StoryboardInfo> {
  final _storyboardApi = StoryboardApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  late Storyboard storyboard;
  List<dynamic> contributors = [];

  @override
  void initState() {
    Storyboard storyboard = storyboardController.currentStoryboard;
    setState(() {
      storyboard = storyboard;
    });
    super.initState();
    _fetchContributors();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _fetchContributors() async {
    if (!mounted) {
      return;
    }
    Storyboard storyboard = storyboardController.currentStoryboard;

    List<dynamic> contribute = await _storyboardApi.getContributors(
        storyboardId: storyboard.storyboardId);
    setState(() {
      contributors = contribute;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20),
      child: Obx(() => Column(
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
                photoUrl: storyboardController.currentStoryboard.photoUrl ?? "",
                title: storyboardController.currentStoryboard.title,
              )),
              const SizedBox(
                height: 20,
              ),
              Semantics(
                  label: storyboardController.currentStoryboard.title,
                  child: Text(
                    storyboardController.currentStoryboard.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  )),
              Row(children: [
                Semantics(
                  label: _i18n.translate("story_contributors"),
                  child: Text(
                    "${_i18n.translate("story_contributors")}: ",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                ...contributors.map((contribute) => Text(
                    "${contribute['character']} ",
                    style: Theme.of(context).textTheme.labelSmall))
              ]),
              const SizedBox(
                height: 20,
              ),
              Semantics(
                  label: storyboardController.currentStoryboard.summary ??
                      "Summary not provided",
                  child: Text(storyboardController.currentStoryboard.summary ??
                      "Summary not provided")),
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom,
              ),
            ],
          )),
    );
  }
}
