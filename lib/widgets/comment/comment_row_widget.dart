import 'package:machi_app/datas/story.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/widgets/timeline/timeline_header.dart';

/// Used on comment widget that lists all comments
/// Used on page widget to create an illusion that new comments are posted
/// (This is done to reduce API calls and querying.)
class CommentRowWidget extends StatelessWidget {
  final StoryComment item;

  const CommentRowWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TimelineHeader(
              showAvatar: true,
              user: item.user,
              showName: true,
              radius: 15,
              timestamp: item.createdAt,
            ),
            Text(
              item.comment,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LikeItemWidget(
                    onLike: (val) {
                      _onLikePressed(item.commentId!, val);
                    },
                    likes: 0,
                    mylikes: 0)
              ],
            ),
            const Divider()
          ],
        ));
  }

  void _onLikePressed(String commentId, bool like) {}
}
