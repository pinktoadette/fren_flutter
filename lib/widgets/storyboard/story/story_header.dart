import 'package:machi_app/datas/story.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/story_cover.dart';

// Story book Onboarding swipe -> child : story_widget
class StoryHeaderWidget extends StatelessWidget {
  final Story story;
  const StoryHeaderWidget({Key? key, required this.story}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double storyCoverWidth = 50;
    double padding = 15;

    return Card(
      elevation: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: InkWell(
                onTap: () async {},
                child: StoryCover(
                    width: storyCoverWidth,
                    height: storyCoverWidth,
                    photoUrl: story.photoUrl ?? "",
                    title: story.title)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(story.title,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.labelMedium),
              Text(story.subtitle,
                  style: Theme.of(context).textTheme.displaySmall),
              Text("${story.pages?.length ?? 0} mods",
                  style: Theme.of(context).textTheme.labelSmall)
            ],
          )
        ],
      ),
    );
  }
}
