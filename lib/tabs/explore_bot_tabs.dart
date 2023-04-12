import 'package:fren_app/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/bot/all_bots_vertical.dart';
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

    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Machi",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const ListAllBotsVertically(),
              ],
            )));
  }
}
