import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
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
import 'package:url_launcher/url_launcher.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppHelper appHelper = AppHelper();
    final i18n = AppLocalizations.of(context);

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
                  i18n.translate("subscription"),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () async {
                  _showSubscription(context);
                },
              ),
            ),

            const Spacer(),
            Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4.0,
                shape: defaultCardBorder(),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Iconsax.document),
                      title: Text(
                        i18n.translate("help_us_improve"),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () async {
                        final Uri url = Uri.parse(SURVEY_FORM);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw "Could not launch url: $url";
                        }
                      },
                    ),
                  ],
                )),

            Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4.0,
                shape: defaultCardBorder(),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Iconsax.note_favorite),
                      title: Text(
                        i18n.translate("release_upcoming_features"),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () async {
                        final Uri url = Uri.parse(RELEASE_DOC);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw "Could not launch url: $url";
                        }
                      },
                    ),
                  ],
                )),

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
                        i18n.translate("settings"),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () {
                        /// Go to profile settings
                        Get.to(() => const SettingsScreen());
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share),
                      title: Text(
                        i18n.translate("share_with_friends"),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () async {
                        appHelper.shareApp();
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
            heightFactor:
                subscribeController.token.netCredits > 0 ? 0.50 : 0.95,
            child: subscribeController.token.netCredits > 0
                ? const SubscribePurchaseDetails()
                : const SubscriptionProduct())));
  }
}
