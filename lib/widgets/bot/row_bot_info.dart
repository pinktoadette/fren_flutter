import 'dart:math';

import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/helpers/truncate_text.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/image/image_rounded.dart';
import 'package:iconsax/iconsax.dart';

class RowMachiInfo extends StatelessWidget {
  final Bot bot;
  bool? showChat = false;
  RowMachiInfo({Key? key, required this.bot, this.showChat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);

    final width = MediaQuery.of(context).size.width;

    return ListTile(
      dense: true,
      minLeadingWidth: width * 0.15,
      isThreeLine: true,
      leading: RoundedImage(
          width: width * 0.15,
          height: width * 0.15,
          icon: const Icon(Iconsax.box_add),
          photoUrl: bot.profilePhoto ?? ""),
      title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          bot.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ]),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(bot.modelType.name, style: Theme.of(context).textTheme.labelSmall),
        Text(
          truncateText(40, bot.about),
          style: Theme.of(context).textTheme.bodySmall,
        )
      ]),
      trailing: ElevatedButton(
        onPressed: () {
          _showBotInfo(context);
        },
        child: showChat == true
            ? Text(_i18n.translate("chat"))
            : Text(_i18n.translate("get")),
      ),
    );
  }

  void _showBotInfo(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: max(height, 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              BotProfileCard(
                bot: bot,
                showPurchase: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}
