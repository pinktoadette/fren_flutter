import 'dart:io';

import 'package:fren_app/helpers/app_helper.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/screens/about_us_screen.dart';
import 'package:fren_app/widgets/default_card_border.dart';
import 'package:fren_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';

class DiscoverCard extends StatelessWidget {
  // Variables
  final AppHelper _appHelper = AppHelper();
  // Text style
  final _textStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );

  DiscoverCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.width;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: defaultCardBorder(),
      child: Container(
        height: 300,
        width: screenWidth,
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [
        //       Colors.yellow,
        //       Colors.orangeAccent,
        //       // Colors.yellow.shade300,
        //     ],
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //   ),
        // ),
        child: Container(
          padding: const EdgeInsets.all(40),
          height: screenheight - 150,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Get Reminders', style: Theme.of(context).textTheme.headlineSmall,),
                const SizedBox(
                  height: 30,
                ),
                const Text("Need a reminder? Let Frankie know and it'll send you a notification"),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: (){}, child: Text("Got It"))
              ],
            ),
            ]
          )
        ),
      ),
    );
  }
}
