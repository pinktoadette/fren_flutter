import 'dart:io';

import 'package:fren_app/helpers/app_helper.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/screens/Miscellaneous/about_us_screen.dart';
import 'package:fren_app/widgets/default_card_border.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:fren_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';

class ButtonChanged extends Notification {
  final bool val;
  ButtonChanged(this.val);
}

class DiscoverCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String btnText;
  final bool showFrankie = true;

  const DiscoverCard({Key? key, required this.title, required this.subtitle, required this.btnText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final _i18n = AppLocalizations.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: defaultCardBorder(),
      child: SizedBox(
        height: screenheight-300,
        width: screenWidth,
        child: Container(
          padding: const EdgeInsets.all(40),
          height: screenheight*0.85,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Frankloader(),
                Text(title, style: Theme.of(context).textTheme.headlineSmall,),
                Text(subtitle),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(onPressed: (){
                  ButtonChanged(true).dispatch(context);
                }, child: Text(btnText))
              ],
            ),
            ]
          )
        ),
      ),
    );
  }
}
