import 'package:get/get.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/helpers/app_helper.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/settings_screen.dart';
import 'package:machi_app/widgets/common/default_card_border.dart';
import 'package:machi_app/widgets/profile_basic_info_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/widgets/subscribe/subscribe_purchase_details.dart';
import 'package:machi_app/widgets/subscribe/subscription_product.dart';
import 'package:scoped_model/scoped_model.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppHelper _appHelper = AppHelper();
    final _i18n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: ScopedModelDescendant<UserModel>(
          builder: (context, child, userModel) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            /// Basic profile info
            const ProfileBasicInfoCard(),

            /// Show subscription dialog
            Card(
              child: ListTile(
                leading: const Icon(Iconsax.buy_crypto),
                title: Text(
                  _i18n.translate("subscription"),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () async {
                  _showSubscription(context);
                },
              ),
            ),
            const Spacer(),

            /// enable dark mode
            Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4.0,
                shape: defaultCardBorder(),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Iconsax.setting),
                      title: Text(
                        _i18n.translate("settings"),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () {
                        /// Go to profile settings
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SettingsScreen()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share),
                      title: Text(
                        _i18n.translate("share_with_friends"),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () async {
                        _appHelper.shareApp();
                      },
                    ),
                  ],
                )),

            /// App Section Card
            // AppSectionCard(),

            /// Delete Account Button
            // const DeleteAccountButton(),
          ],
        );
      }),
    );
  }

  void _showSubscription(BuildContext context) {
    final SubscribeController subscribeController = Get.find(tag: 'subscribe');

    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => Obx(() => FractionallySizedBox(
            heightFactor: subscribeController.credits.value > 0 ? 0.50 : 0.98,
            child: subscribeController.credits.value > 0
                ? const SubscribePurchaseDetails()
                : const SubscriptionProduct())));
  }
}
