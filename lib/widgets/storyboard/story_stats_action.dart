import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';

class StoryStatsAction extends StatefulWidget {
  final Storyboard story;
  const StoryStatsAction({Key? key, required this.story}) : super(key: key);

  @override
  State<StoryStatsAction> createState() => _StoryStatsActionState();
}

class _StoryStatsActionState extends State<StoryStatsAction> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          children: [
            Text(
              "3 Comments",
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.left,
            ),
            const Spacer(),
            LikeButton(
              bubblesColor: BubblesColor(
                dotPrimaryColor: APP_ACCENT_COLOR,
                dotSecondaryColor: Theme.of(context).primaryColor,
              ),
              likeBuilder: (bool isLiked) {
                return Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? APP_ACCENT_COLOR : Colors.grey,
                );
              },
              likeCount: 10,
            )
          ],
        ));
  }
}
