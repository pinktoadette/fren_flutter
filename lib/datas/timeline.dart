import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/storyboard.dart';

class Timeline {
  final String id;
  final String comment;
  final String postType;
  final dynamic subText;
  final int createdAt;
  final int updatedAt;
  final StoryUser user;
  final ShortStoryboard shortboard;

  Timeline(
      {required this.id,
      required this.comment,
      required this.postType,
      required this.subText,
      required this.createdAt,
      required this.updatedAt,
      required this.user,
      required this.shortboard});

  factory Timeline.fromJson(Map<String, dynamic> doc) {
    StoryUser user = StoryUser.fromDocument(doc[STORY_CREATED_BY]);
    ShortStoryboard story = ShortStoryboard.fromDocument(doc["storyboard"]);

    return Timeline(
        id: doc[STORY_ID],
        comment: doc[STORY_COMMENT],
        postType: doc[STORY_POST_TYPE],
        subText: doc[STORY_POST_SUB_TEXT],
        user: user,
        createdAt: doc[CREATED_AT],
        updatedAt: doc[UPDATED_AT],
        shortboard: story);
  }
}
