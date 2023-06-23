import 'package:flutter/material.dart';
import 'package:machi_app/widgets/bot/list_all_bots.dart';

/// Gets recent new bots
/// Gets most installed bots
/// Save a copy of bots in local, find newest
class ExploreMachi extends StatelessWidget {
  const ExploreMachi({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListPromptBots();
  }
}
