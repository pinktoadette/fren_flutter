import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/screens/storyboard/create_new/create_new_board.dart';
import 'package:machi_app/screens/storyboard/create_new/quick_create.dart';

class CreateNewSelection extends StatelessWidget {
  const CreateNewSelection({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations i18n = AppLocalizations.of(context);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leadingWidth: 20,
          centerTitle: false,
          title: Text(
            i18n.translate("creative_mix_new_board"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buttonSelection(
                  context,
                  i18n.translate("creative_mix_help_me"),
                  i18n.translate("creative_mix_help_me_info"),
                  Iconsax.cloud_lightning,
                  const QuickCreateNewBoard()),
              const SizedBox(
                height: 20,
              ),
              _buttonSelection(
                  context,
                  i18n.translate("creative_mix_manual"),
                  i18n.translate("creative_mix_manual_info"),
                  Iconsax.activity,
                  const ManaulCreateNewBoard()),
              const SizedBox(
                height: 100,
              ),
              const Spacer(),
            ],
          ),
        ));
  }

  Widget _buttonSelection(BuildContext context, String title, String subtitle,
      IconData icon, Widget widget) {
    double buttonSize = 200;
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: OutlinedButton.icon(
        onPressed: () {
          Get.to(() => widget);
        },
        label: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        icon: Icon(
          icon,
          color: APP_ACCENT_COLOR,
        ),
      ),
    );
  }
}
