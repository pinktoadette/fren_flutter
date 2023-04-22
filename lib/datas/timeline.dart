import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/storyboard.dart';

class Timeline {
  final String id;
  final String postType;
  final String text;
  final dynamic subText;
  final int createdAt;
  final int updatedAt;
  final StoryUser user;
  final String? photoUrl;
  final int? likes;

  Timeline(
      {required this.id,
      required this.postType,
      required this.text,
      required this.subText,
      required this.createdAt,
      required this.updatedAt,
      required this.user,
      required this.photoUrl,
      required this.likes});

  factory Timeline.fromJson(Map<String, dynamic> doc) {
    StoryUser user = StoryUser.fromDocument(doc[STORY_CREATED_BY]);

    return Timeline(
        id: doc[TIMELINE_ID],
        postType: doc[STORY_POST_TYPE],
        text: doc[STORY_POST_TEXT],
        subText: doc[STORY_POST_SUB_TEXT],
        user: user,
        photoUrl: doc[BOT_PROFILE_PHOTO] ?? "",
        createdAt: doc[CREATED_AT],
        updatedAt: doc[UPDATED_AT],
        likes: doc[ITEM_LIKES]["count"] ?? 0);
  }
}
