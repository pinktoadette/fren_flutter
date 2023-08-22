import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/bot/list_all_bots.dart';

class ExploreMachi extends StatefulWidget {
  const ExploreMachi({super.key});
  @override
  State<ExploreMachi> createState() => _ExploreMachiState();
}

class _ExploreMachiState extends State<ExploreMachi> {
  late AppLocalizations _i18n;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 50,
        centerTitle: false,
        title: Text(
          _i18n.translate("search"),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: const ListPromptBots(),
    );
  }
}
