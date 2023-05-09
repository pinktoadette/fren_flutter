import 'package:machi_app/helpers/app_helper.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/subscribe/subscription.dart';
import 'package:iconsax/iconsax.dart';

class SubscribeDialog extends StatelessWidget {
  const SubscribeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    children: <Widget>[
                      /// User image
                      const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Iconsax.element_plus)),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(i18n.translate("subscription"),
                            style: const TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Theme.of(context).primaryColor,
                          backgroundImage:
                              NetworkImage(UserModel().user.userProfilePhoto),
                        ),
                        title: Text(
                            '${i18n.translate("hello")} ${UserModel().user.userFullname.split(' ')[0]}, '
                            '${i18n.translate("become_a_subscription_member")}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                            textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 8)
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                      icon: const Icon(Icons.cancel,
                          color: Colors.white, size: 35),
                      onPressed: () {
                        /// Close Dialog
                        Navigator.of(context).pop();
                      }),
                )
              ],
            ),

            /// VIP Plans
            Container(
              color: Colors.grey.withAlpha(70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(i18n.translate("subscription"),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 10, thickness: 1),

                  /// VIP Subscriptions
                  Subscription(
                    priceColor: Colors.green,
                    icon: Image.asset('assets/images/crow_badge.png',
                        width: 50, height: 50),
                  ),
                  const Divider(thickness: 1, height: 30),

                  // Show Restore VIP Subscription button
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            i18n.translate(
                                'have_you_already_purchased_a_VIP_account'),
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        // Restore subscription button
                        TextButton.icon(
                          icon: const Icon(Icons.refresh),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ))),
                          label: Text(i18n.translate('restore_subscription')),
                          onPressed: () async {
                            // Restore VIP subscription
                            AppHelper().restoreVipAccount(showMsg: true);
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
