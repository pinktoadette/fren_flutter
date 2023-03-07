import 'package:fren_app/dialogs/vip_dialog.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/default_card_border.dart';
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
        title: Text(i18n.translate("subscription"),
            style: const TextStyle(fontSize: 18)),
        onTap: () {
          /// Show VIP dialog
          showDialog(context: context, 
            builder: (context) => const VipDialog());
        },
      ),
    );
  }
}
