import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';

class TipWidget extends StatelessWidget {
  late AppLocalizations _i18n;

  TipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    _i18n = AppLocalizations.of(context);

    List<String> items = [
      _i18n.translate("tips_1"),
      _i18n.translate("tips_2"),
      _i18n.translate("tips_3"),
      _i18n.translate("tips_4"),
      _i18n.translate("tips_5"),
    ];

    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((e) {
            return Container(
              padding: const EdgeInsets.all(2),
              width: width * 0.9,
              // height: 40,
              child: Card(
                child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      e,
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
              ),
            );
          }).toList(),
        ));
  }
}
