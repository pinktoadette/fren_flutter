import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/story.dart';

// ignore: constant_identifier_names
enum StoryStatus { UNPUBLISHED, PUBLISHED, BLOCKED }

class ShortStoryboard {
  final String storyboardId;
  final String title;
  ShortStoryboard({
    required this.storyboardId,
    required this.title,
  });
  factory ShortStoryboard.fromDocument(Map<String, dynamic> doc) {
    return ShortStoryboard(
        storyboardId: doc[STORY_ID], title: doc[STORY_TITLE]);
  }
}

class StoryUser {
  final String userId;
  final String photoUrl;
  final String username;

  StoryUser(
      {required this.userId, required this.photoUrl, required this.username});

  factory StoryUser.fromDocument(Map<String, dynamic> doc) {
    return StoryUser(
        userId: doc[USER_ID],
        photoUrl: doc[USER_PROFILE_PHOTO] ?? "",
        username: doc[USER_USERNAME]);
  }
}

class Storyboard {
  final String title;
  final String storyboardId;
  final String? summary;
  final String category;
  final String? photoUrl;
  late List<Story>? story;
  final StoryUser createdBy;
  final int createdAt;
  final int updatedAt;
  final StoryStatus status;
  final int? likes;
  final int? mylikes;
  final int? commentCount;

  Storyboard(
      {required this.title,
      required this.story,
      required this.storyboardId,
      required this.summary,
      required this.category,
      required this.createdBy,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      this.photoUrl,
      this.likes,
      this.mylikes,
      this.commentCount});

  Storyboard copyWith(
      {String? title,
      List<Story>? story,
      StoryUser? createdBy,
      String? storyboardId,
      String? summary,
      String? category,
      StoryStatus? status,
      int? createdAt,
      int? updatedAt,
      String? photoUrl,
      int? likes,
      int? mylikes,
      int? commentCount}) {
    return Storyboard(
        title: title ?? this.title,
        story: story ?? this.story,
        storyboardId: storyboardId ?? this.storyboardId,
        summary: summary ?? this.summary,
        category: category ?? this.category,
        createdBy: createdBy ?? this.createdBy,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        photoUrl: photoUrl ?? this.photoUrl,
        likes: likes ?? this.likes,
        mylikes: mylikes ?? this.mylikes,
        commentCount: commentCount ?? this.commentCount);
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'title': title,
      'category': category,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'story': story,
      'status': status,
      'storyboardId': storyboardId,
      'createdBy': createdBy,
      'photoUrl': photoUrl,
      'likes': likes,
      'mylikes': mylikes,
      'commentCount': commentCount
    };
  }

  factory Storyboard.fromJson(Map<String, dynamic> doc) {
    StoryUser user = StoryUser.fromDocument(doc[STORY_CREATED_BY]);

    List<Story> listScene = [];
    if (doc.containsKey(STORY)) {
      doc[STORY].forEach((sto) {
        Story s =
            Story.fromJson({...sto, STORY_CREATED_BY: doc[STORY_CREATED_BY]});
        listScene.add(s);
      });
    }
    return Storyboard(
        storyboardId: doc[STORYBOARD_ID],
        title: doc[STORYBOARD_TITLE],
        createdBy: user,
        category: doc[STORYBOARD_CATEGORY] ?? "Other",
        summary: doc[STORYBOARD_SUMMARY],
        story: listScene,
        status: StoryStatus.values.byName(doc[STORY_STATUS]),
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt(),
        photoUrl: doc[STORYBOARD_PHOTO_URL] ?? "",
        likes: doc[ITEM_LIKES] ?? 0,
        mylikes: doc[ITEM_MY_LIKES] ?? 0,
        commentCount: doc[COMMENT_COUNT] ?? 0);
  }
}
