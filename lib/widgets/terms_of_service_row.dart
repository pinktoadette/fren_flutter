import 'package:machi_app/helpers/app_helper.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';

class TermsOfServiceRow extends StatelessWidget {
  // Params
  final Color color;

  TermsOfServiceRow({Key? key, this.color = Colors.white}) : super(key: key);

  // Private variables
  final _appHelper = AppHelper();

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          child: Text(
            i18n.translate("terms_of_service"),
            style: TextStyle(
                color: color,
                fontSize: 10,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold),
          ),
          onTap: () {
            // Open terms of service page in browser
            _appHelper.openTermsPage();
          },
        ),
        Text(
          ' | ',
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          child: Text(
            i18n.translate("privacy_policy"),
            style: TextStyle(
                color: color,
                fontSize: 10,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold),
          ),
          onTap: () {
            // Open privacy policy page in browser
            _appHelper.openPrivacyPage();
          },
        ),
      ],
    );
  }
}
