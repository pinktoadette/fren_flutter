import 'package:flutter/material.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/bot/list_all_bots.dart';
import 'package:fren_app/widgets/search_bot.dart';
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

  final BotController botController = Get.find(tag: 'bot');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: SizedBox(
              width: screenWidth - 100, child: const SearchMachiWidget()),
        ),
        body: const ListPromptBots());
  }
}
