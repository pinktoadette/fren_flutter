import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/bot/list_all_bots.dart';

/// Gets recent new bots
/// Gets most installed bots
/// Save a copy of bots in local, find newest
class ExploreMachi extends StatelessWidget {
  const ExploreMachi({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Text(
          i18n.translate("search"),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        // Customize AppBar color, text color, etc. here
      ),
      body: const SafeArea(
        child: ListPromptBots(),
      ),
    );
  }
}
