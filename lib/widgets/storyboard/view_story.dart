import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/audio/mini_play_control.dart';
import 'package:machi_app/widgets/story_cover.dart';

// View details of each message
class ViewStory extends StatefulWidget {
  final Storyboard storyboard;
  const ViewStory({Key? key, required this.storyboard}) : super(key: key);

  @override
  _ViewStoryState createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    double imageWidth = 80;
    double imageHeight = 80;
    double padding = 10;
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: widget.storyboard.story!.length,
        itemBuilder: (BuildContext ctx, index) {
          return Container(
              padding: EdgeInsets.all(padding),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                StoryCover(
                    width: imageWidth,
                    height: imageHeight,
                    photoUrl: widget.storyboard.story![index].photoUrl ?? "",
                    title: widget.storyboard.story![index].title),
                SizedBox(
                    width:
                        width - (PLAY_BUTTON_WIDTH + imageWidth + padding * 2),
                    height: imageHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.storyboard.story![index].title,
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          widget.storyboard.story![index].subtitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )),
                MiniAudioWidget(post: widget.storyboard)
              ]));
        });
  }
}
