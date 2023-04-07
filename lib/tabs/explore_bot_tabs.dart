import 'package:fren_app/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/controller/bot_controller.dart';
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
  final BotController botController = Get.find();
  final UserController userController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Column(
      children: <Widget>[
        ListAllBotsVertically(),
      ],
    ));
  }
}
