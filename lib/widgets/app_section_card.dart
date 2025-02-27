import 'dart:io';

import 'package:machi_app/helpers/app_helper.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/common/default_card_border.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AppSectionCard extends StatelessWidget {
  // Variables
  final AppHelper _appHelper = AppHelper();
  // Text style
  final _textStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );

  AppSectionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);

    return Card(
      elevation: 4.0,
      shape: defaultCardBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(i18n.translate("application"),
                style: const TextStyle(fontSize: 20, color: Colors.grey),
                textAlign: TextAlign.left),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Iconsax.star),
            title: Text(
                i18n.translate(Platform.isAndroid
                    ? "rate_on_play_store"
                    : "rate_on_app_store"),
                style: _textStyle),
            onTap: () async {
              /// Rate app
              _appHelper.reviewApp();
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Iconsax.lock),
            title: Text(i18n.translate("privacy_policy"), style: _textStyle),
            onTap: () async {
              /// Go to privacy policy
              _appHelper.openPrivacyPage();
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.copyright_outlined, color: Colors.grey),
            title: Text(i18n.translate("terms_of_service"), style: _textStyle),
            onTap: () async {
              /// Go to privacy policy
              _appHelper.openTermsPage();
            },
          ),
        ],
      ),
    );
  }
}
