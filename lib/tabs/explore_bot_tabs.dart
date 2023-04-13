import 'package:fren_app/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/bot/list_all_bots.dart';
import 'package:fren_app/widgets/search_bot.dart';
import 'package:fren_app/widgets/search_user.dart';
import 'package:get/get.dart';

/// Gets recent new bots
/// Gets most installed bots
/// Save a copy of bots in local, find newest
class ExploreBotTab extends StatefulWidget {
  const ExploreBotTab({Key? key}) : super(key: key);

  @override
  _ExploreBotState createState() => _ExploreBotState();
}

class _ExploreBotState extends State<ExploreBotTab> {
  late AppLocalizations _i18n;

  final BotController botController = Get.find();
  final UserController userController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Models",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(
                        width: screenWidth * 0.4, child: SearchMachiWidget())
                  ]),
              bottom: TabBar(
                tabs: [
                  Tab(
                    text: _i18n.translate("bot_prompt_models"),
                  ),
                  Tab(
                    text: _i18n.translate("bot_text_to_image"),
                  ),
                  Tab(
                    text: _i18n.translate("bot_image_to_text"),
                  ),
                ],
              ),
            ),
            body: const Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: TabBarView(
                children: [
                  ListAllBots(),
                  Icon(Icons.directions_transit),
                  Icon(Icons.directions_bike),
                ],
              ),
            )));
  }
}
