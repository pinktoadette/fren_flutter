import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 4 / 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20),
          itemCount: _listStories.length,
          itemBuilder: (BuildContext ctx, index) {
            return Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.black,
                      strokeAlign: BorderSide.strokeAlignCenter),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_listStories[index][STORY_TITLE],
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black)),
                    _showMessage(_listStories[index][STORY_MESSAGES]),
                  ]),
            );
          }),
    );
  }

  Widget _showMessage(dynamic message) {
    if (message.isEmpty) {
      return SizedBox.shrink();
    }
    switch (message[0][STORY_MESSAGE_TYPE]) {
      case ('text'):
        return Flexible(
            child: Text(
          message[0][STORY_MESSAGE_TEXT],
          style: const TextStyle(fontSize: 10, color: Colors.black),
        ));
      case ('image'):
        return Container(
            constraints: const BoxConstraints.expand(),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(message[0][STORY_MESSAGE_URI]),
                  fit: BoxFit.cover),
            ));
      default:
        return const Icon(Iconsax.box_add);
    }
  }
}
