import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/storytab_controller.dart';
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
  final _tabController = Get.put(StoryTabController());
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 30,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 20, top: 0),
              child: Text(
                _i18n.translate("storycast_board"),
                style: Theme.of(context).textTheme.headlineMedium,
              )),
          const SizedBox(
            height: 10,
          ),
          TabBar(
            indicatorWeight: 2,
            indicatorPadding: const EdgeInsets.only(bottom: 8, top: 2),
            labelColor: Colors.white,
            controller: _tabController.tabController,
            tabs: <Widget>[
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _i18n.translate("storyboard"),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _i18n.translate("story_published"),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
              child: TabBarView(
            controller: _tabController.tabController,
            children: const <Widget>[
              ListMyStoryboard(),
              ListMyPublishedStories()
            ],
          ))
        ],
      ),
    );
  }
}
