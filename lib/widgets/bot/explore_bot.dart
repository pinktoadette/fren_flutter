import 'package:flutter/material.dart';
import 'package:machi_app/widgets/bot/list_all_bots.dart';
import 'package:machi_app/widgets/search_bot.dart';

/// Gets recent new bots
/// Gets most installed bots
/// Save a copy of bots in local, find newest
class ExploreMachi extends StatelessWidget {
  const ExploreMachi({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
        child: Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: SearchMachiWidget(),
        ),
        ListPromptBots(),
      ],
    ));
  }
}
