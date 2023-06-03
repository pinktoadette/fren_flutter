import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:machi_app/constants/constants.dart';

/// Like any item (board, story, bot etc), saved to callback on like
class LikeItemWidget extends StatelessWidget {
  final int likes;
  final int mylikes;
  final double? size;
  final Function(dynamic data) onLike;

  const LikeItemWidget(
      {Key? key,
      required this.onLike,
      required this.likes,
      required this.mylikes,
      this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      size: size ?? 20,
      isLiked: mylikes == 1 ? true : false,
      onTap: (value) async {
        onLike(!value);
        return !value;
      },
      bubblesColor: BubblesColor(
        dotPrimaryColor: APP_LIKE_COLOR,
        dotSecondaryColor: Theme.of(context).primaryColor,
      ),
      likeBuilder: (bool isLiked) {
        return Icon(isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? APP_LIKE_COLOR : Colors.grey, size: 18);
      },
      likeCount: likes,
      countDecoration: (count, likeCount) {
        return Text(likeCount.toString(),
            style: Theme.of(context).textTheme.labelSmall);
      },
    );
  }
}
