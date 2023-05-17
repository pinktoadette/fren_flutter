import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';

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
        photoUrl: doc[USER_PROFILE_PHOTO],
        username: doc[USER_USERNAME]);
  }
}

class StoryComment {
  final String comment;
  final int createdAt;
  final int updatedAt;
  final StoryUser user;
  final ShortStoryboard shortStory;

  StoryComment({
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.shortStory,
  });

  factory StoryComment.fromDocument(Map<String, dynamic> doc) {
    StoryUser user = StoryUser.fromDocument(doc["user"]);
    ShortStoryboard story = ShortStoryboard.fromDocument(doc["storyboard"]);
    return StoryComment(
        comment: doc[STORY_COMMENT],
        user: user,
        shortStory: story,
        createdAt: doc[CREATED_AT],
        updatedAt: doc[UPDATED_AT]);
  }
}

class Storyboard {
  /// Using types and Chatroom together
  final String title;
  final String storyboardId;
  final String? summary;
  final String category;
  final String? photoUrl;
  final List<Story>? story;
  final StoryUser createdBy;
  final int createdAt;
  final int updatedAt;
  final StoryStatus status;
  final int? likes;
  final int? mylikes;

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
      this.mylikes});

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
      int? mylikes}) {
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
        mylikes: mylikes ?? this.mylikes);
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
      'mylikes': mylikes
    };
  }

  factory Storyboard.fromJson(Map<String, dynamic> doc) {
    StoryUser user = StoryUser.fromDocument(doc[STORY_CREATED_BY]);

    List<Story> listScene = [];
    doc[STORY].forEach((sto) {
      Story s =
          Story.fromJson({...sto, STORY_CREATED_BY: doc[STORY_CREATED_BY]});
      listScene.add(s);
    });

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
        likes: doc.containsKey(ITEM_LIKES) ? doc[ITEM_LIKES][ITEM_LIKES] : 0,
        mylikes: doc.containsKey(ITEM_MY_LIKES)
            ? doc[ITEM_MY_LIKES][ITEM_LIKES]
            : 0);
  }
}
