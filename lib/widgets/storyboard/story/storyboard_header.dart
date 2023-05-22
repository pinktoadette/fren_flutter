import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/story_cover.dart';

// Story book Onboarding swipe -> child : story_widget
class StoryboardHeaderWidget extends StatelessWidget {
  final Storyboard storyboard;
  const StoryboardHeaderWidget({Key? key, required this.storyboard})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
                    photoUrl: storyboard.photoUrl ?? "",
                    title: storyboard.title)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(storyboard.category,
                  style: const TextStyle(
                      fontSize: 10,
                      color: APP_SECONDARY_ACCENT_COLOR,
                      fontWeight: FontWeight.bold)),
              SizedBox(
                width: width - (padding * 2 + storyCoverWidth + 10),
                height: 45,
                child: Text(storyboard.title,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.labelMedium),
              ),
              Text("${storyboard.story?.length ?? 0} collection",
                  style: Theme.of(context).textTheme.labelSmall)
            ],
          )
        ],
      ),
    );
  }
}
