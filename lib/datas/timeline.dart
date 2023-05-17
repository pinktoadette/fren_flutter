import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/storyboard.dart';

class Timeline {
  final String id;
  final String text;
  final dynamic subText;
  final int createdAt;
  final int updatedAt;
  final StoryUser user;
  final String? photoUrl;
  final int? likes;
  final int? mylikes;
  final bool? mymachi;

  Timeline(
      {required this.id,
      required this.text,
      required this.subText,
      required this.createdAt,
      required this.updatedAt,
      required this.user,
      required this.photoUrl,
      required this.likes,
      required this.mylikes,
      required this.mymachi});

  factory Timeline.fromJson(Map<String, dynamic> doc) {
    StoryUser user = StoryUser.fromDocument(doc[STORY_CREATED_BY]);

    return Timeline(
        id: doc[STORYBOARD_ID],
        text: doc[STORYBOARD_TITLE],
        subText: doc[STORYBOARD_SUBTITLE],
        user: user,
        photoUrl: doc[BOT_PROFILE_PHOTO] ?? "",
        createdAt: doc[CREATED_AT],
        updatedAt: doc[UPDATED_AT],
        likes: doc[ITEM_LIKES] == null ? 0 : doc[ITEM_LIKES]["likes"] ?? 0,
        mylikes:
            doc[ITEM_MY_LIKES] == null ? 0 : doc[ITEM_MY_LIKES]["likes"] ?? 0,
        mymachi: doc[SUBSCRIBED_MACHI] == null
            ? false
            : doc[SUBSCRIBED_MACHI][IS_SUBSCRIBED]);
  }
}
