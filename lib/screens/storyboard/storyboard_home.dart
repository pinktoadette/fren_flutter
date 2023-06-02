import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/storyboard/my_items/list_my_board.dart';
import 'package:machi_app/widgets/storyboard/my_items/list_my_published_board.dart';

class Storyboard extends StatefulWidget {
  const Storyboard({Key? key}) : super(key: key);

  @override
  _StoryboardState createState() => _StoryboardState();
}

class _StoryboardState extends State<Storyboard> with TickerProviderStateMixin {
  late AppLocalizations _i18n;
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
          title: Text(
            _i18n.translate("storyboard"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: [
            Container(
                padding: const EdgeInsets.all(10.0),
                child: TextButton(
                    onPressed: () {
                      Get.to(() => const ListPublishBoard());
                    },
                    child: Text(_i18n.translate("story_published"))))
          ]),
      body: const ListPrivateBoard(),
    );
  }
}
