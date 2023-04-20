import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoryStatsAction extends StatefulWidget {
  final Storyboard story;
  const StoryStatsAction({Key? key, required this.story}) : super(key: key);

  @override
  _StoryStatsActionState createState() => _StoryStatsActionState();
}

class _StoryStatsActionState extends State<StoryStatsAction> {
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

    return Row(
      children: [
        Text(
          "343 Views",
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.left,
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          "53 Likes",
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}
