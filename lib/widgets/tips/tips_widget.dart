import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';

class TipWidget extends StatelessWidget {
  const TipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    AppLocalizations _i18n = AppLocalizations.of(context);

    List<String> items = [
      _i18n.translate("tips_1"),
      _i18n.translate("tips_2"),
      _i18n.translate("tips_3"),
      _i18n.translate("tips_4"),
      _i18n.translate("tips_5"),
    ];

    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          const Card(
            child: Icon(
              Icons.lightbulb,
              color: APP_ACCENT_COLOR,
            ),
          ),
          ...items.map((e) {
            return SizedBox(
              width: width * 0.9,
              child: Card(
                child: Container(
                    height: 80,
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      e,
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
              ),
            );
          }).toList(),
        ]));
  }
}
