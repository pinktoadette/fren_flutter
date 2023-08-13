import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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
  final _cancelToken = CancelToken();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    /// prefetch published
    _getPublished();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cancelToken.cancel();
    super.dispose();
  }

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
            child: TextButton.icon(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              onPressed: () async {},
              label: Text(_i18n.translate("creative_mix_collection")),
              icon: const Icon(Iconsax.add),
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: _i18n.translate("creative_mix_private")),
            Tab(text: _i18n.translate("creative_mix_published")),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ListPrivateBoard(),
          ListPublishBoard(),
        ],
      ),
    );
  }

  void _getPublished() async {
    await storyboardController.getBoards(
        filter: StoryStatus.PUBLISHED, cancelToken: _cancelToken);
  }
}
