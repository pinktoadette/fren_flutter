import 'package:flutter/material.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/storyboard/list_my_story.dart';

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
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            _i18n.translate("storyboard"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: height - 300,
                child: const MyStories(
                  isAdd: false,
                ),
              )
            ],
          ),
        ));
  }
}
