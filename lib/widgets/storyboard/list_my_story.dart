import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/widgets/gallery_image_card.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class MyStories extends StatefulWidget {
  const MyStories({Key? key}) : super(key: key);

  @override
  _MyStoriesState createState() => _MyStoriesState();
}

class _MyStoriesState extends State<MyStories> {
  late AppLocalizations _i18n;
  final _storyApi = StoryApi();
  List _listStories = [];

  _fetchMyStory() async {
    final stories = await _storyApi.getMyStories();
    setState(() {
      _listStories = stories;
    });
  }

  @override
  void initState() {
    _fetchMyStory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // implement GridView.builder
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20),
          itemCount: _listStories.length,
          itemBuilder: (BuildContext ctx, index) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.amber, borderRadius: BorderRadius.circular(15)),
              child: Text(_listStories[index][STORY_TITLE]),
            );
          }),
    );
  }
}
