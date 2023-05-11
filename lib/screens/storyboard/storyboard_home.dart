import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/storytab_controller%20copy.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/storyboard/list_my_board.dart';
import 'package:machi_app/widgets/storyboard/list_published_board.dart';

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
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: width,
        leading: TabBar(
          indicatorWeight: 10,
          indicatorPadding:
              const EdgeInsets.only(bottom: 8, top: 2, right: 5, left: 5),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(
              10.0,
            ),
            color: Theme.of(context).colorScheme.background,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
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
      ),
      body: TabBarView(
        controller: _tabController.tabController,
        children: const <Widget>[ListMyStories(), ListMyPublishedStories()],
      ),
    );
  }
}
