import 'package:flutter/material.dart';
import 'package:fren_app/helpers/app_localizations.dart';

/// Gets recent new bots
/// Gets most installed bots
/// Save a copy of bots in local, find newest
class Storyboard extends StatefulWidget {
  const Storyboard({Key? key}) : super(key: key);

  @override
  _StoryboardState createState() => _StoryboardState();
}

class _StoryboardState extends State<Storyboard> {
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _i18n.translate("story"),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            )));
  }
}
