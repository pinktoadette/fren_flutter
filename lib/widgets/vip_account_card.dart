import 'package:machi_app/dialogs/subscribe_dialog.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/default_card_border.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class VipAccountCard extends StatelessWidget {
  const VipAccountCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: defaultCardBorder(),
      child: ListTile(
        leading: const Icon(Iconsax.element_plus),
        title: Text(
          i18n.translate("subscription"),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        onTap: () {
          /// Show VIP dialog
          showDialog(
              context: context, builder: (context) => const SubscribeDialog());
        },
      ),
    );
  }
}
