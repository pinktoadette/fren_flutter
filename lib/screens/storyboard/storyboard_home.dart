import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/storyboard/my_items/list_my_board.dart';
import 'package:machi_app/widgets/storyboard/my_items/list_my_published_board.dart';

class StoryboardHome extends StatefulWidget {
  const StoryboardHome({Key? key}) : super(key: key);

  @override
  State<StoryboardHome> createState() => _StoryboardState();
}

class _StoryboardState extends State<StoryboardHome>
    with TickerProviderStateMixin {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
          centerTitle: false,
          title: Text(
            _i18n.translate("creative_mix"),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          automaticallyImplyLeading: false,
          actions: [
            Container(
                padding: const EdgeInsets.all(10.0),
                child: TextButton(
                    style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.bodyMedium),
                    onPressed: () async {
                      await storyboardController.getBoards(
                          filter: StoryStatus.PUBLISHED);
                      Get.to(() => const ListPublishBoard());
                    },
                    child: Text(_i18n.translate("creative_mix_published"))))
          ]),
      body: const ListPrivateBoard(),
    );
  }
}
