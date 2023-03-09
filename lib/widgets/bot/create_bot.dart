import 'package:fren_app/screens/bot/add_bot_screen.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/screens/bot/manage_bot_screen.dart';
import 'package:fren_app/widgets/default_card_border.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CreateBotCard extends StatelessWidget {
  const CreateBotCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: defaultCardBorder(),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Iconsax.box_tick),
            title: Text(i18n.translate("create_bot"),
                style: const TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddBotScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.box_remove),
            title: Text(i18n.translate("manage_bot"),
                style: const TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ManageBotScreen()));
            },
          ),
        ],
      )
    );
  }
}
