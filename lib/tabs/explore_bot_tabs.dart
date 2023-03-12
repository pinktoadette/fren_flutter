import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/api/bot_api.dart';
import 'package:fren_app/controller/chat_controller.dart';
import 'package:fren_app/controller/user_controller.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/screens/blocked_account_screen.dart';
import 'package:fren_app/screens/first_time/update_location_sceen.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/helpers/app_helper.dart';
import 'package:fren_app/screens/update_app_screen.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/widgets/bot/all_bots_vertical.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/bot/new_bots.dart';
import 'package:fren_app/widgets/bot/popular_bots.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/home_screen.dart';
import 'package:fren_app/screens/first_time/sign_up_screen.dart';
import 'package:fren_app/screens/sign_in_screen.dart';
import 'package:fren_app/widgets/search.dart';
import 'package:get/get.dart';
import '../screens/first_time/on_boarding_screen.dart';

/// Gets recent new bots
/// Gets most installed bots
/// Save a copy of bots in local, find newest
class ExploreBotTab extends StatefulWidget {
  const ExploreBotTab({Key? key}) : super(key: key);

  @override
  _ExploreBotState createState() => _ExploreBotState();
}

class _ExploreBotState extends State<ExploreBotTab> {
  final BotController botController = Get.put(BotController());
  final UserController userController = Get.put(UserController());


  late AppLocalizations _i18n;


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: const <Widget>[
          SearchBar(),
          ListAllBotsVertically(),
        ],
      )
    );
  }
}
