import 'package:flutter/material.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/bot/list_all_bots.dart';
import 'package:machi_app/widgets/search_bot.dart';
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
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false, title: const SearchMachiWidget()),
        body: const ListPromptBots());
  }
}
