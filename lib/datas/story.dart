import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/storyboard.dart';

class StoryComment {
  String comment;
  String? commentId;
  int createdAt;
  int updatedAt;
  StoryUser user;
  int? likes;
  int? mylikes;

  StoryComment(
      {required this.comment,
      required this.createdAt,
      required this.updatedAt,
      required this.user,
      this.commentId,
      this.likes,
      this.mylikes});

  factory StoryComment.fromDocument(Map<String, dynamic> doc) {
    StoryUser user = StoryUser.fromDocument(doc["user"]);
    return StoryComment(
      comment: doc[STORY_COMMENT],
      user: user,
      commentId: doc[COMMENT_ID],
      likes: doc[ITEM_LIKES],
      mylikes: doc[ITEM_MY_LIKES],
      createdAt: doc[CREATED_AT],
      updatedAt: doc[UPDATED_AT],
    );
  }
}

class StoryPages {
  final List<Script>? scripts;
  final int? pageNum;
  StoryPages({this.scripts, this.pageNum});

  factory StoryPages.fromJson(Map<String, dynamic> doc) {
    List<Script> scripts = [];

    if (doc[SCRIPTS].isNotEmpty) {
      doc[SCRIPTS].forEach((page) {
        Script s = Script.fromJson(page);
        scripts.add(s);
      });
    }
    StoryPages pages =
        StoryPages(pageNum: doc[SCRIPT_PAGE_NUM], scripts: scripts);
    return pages;
  }

  StoryPages copyWith({List<Script>? scripts, int? pageNum}) {
    return StoryPages(
        pageNum: pageNum ?? this.pageNum, scripts: scripts ?? this.scripts);
  }
}

class Story {
  final String storyId;
  final String title;
  final String subtitle;
  final String? summary;
  final StoryUser createdBy;
  final StoryStatus status;
  final String? photoUrl;
  final String category;
  List<StoryPages>? pages;
  final int? likes;
  final int? mylikes;
  final int? createdAt;
  final int? updatedAt;
  final int? commentCount;

  Story(
      {required this.storyId,
      required this.title,
      required this.subtitle,
      required this.createdBy,
      required this.status,
      this.photoUrl,
      this.summary,
      required this.category,
      this.likes,
      this.mylikes,
      this.commentCount,
      this.pages,
      this.createdAt,
      this.updatedAt});

  Story copyWith(
      {String? storyId,
      String? title,
      String? subtitle,
      StoryUser? createdBy,
      StoryStatus? status,
      List<StoryPages>? pages,
      String? photoUrl,
      String? category,
      int? likes,
      int? mylikes,
      int? commentCount,
      String? summary}) {
    return Story(
        storyId: storyId ?? this.storyId,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        createdBy: createdBy ?? this.createdBy,
        status: status ?? this.status,
        pages: pages ?? this.pages,
        summary: summary ?? this.summary,
        photoUrl: photoUrl ?? this.photoUrl,
        likes: likes ?? this.likes,
        mylikes: mylikes ?? this.mylikes,
        commentCount: commentCount ?? this.commentCount,
        category: category ?? this.category);
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      STORY_ID: storyId,
      STORY_TITLE: title,
      STORY_SUBTITLE: subtitle,
      STORY_CATEGORY: category,
      STORY_STATUS: status,
      STORY_PHOTO_URL: photoUrl,
      STORY_SUMMARY: summary,
      BOT_CREATED_BY: createdBy,
      ITEM_MY_LIKES: mylikes,
      ITEM_LIKES: likes,
      CREATED_AT: createdAt,
      UPDATED_AT: updatedAt,
    };
  }

  factory Story.fromJson(Map<String, dynamic> doc) {
    StoryUser user = StoryUser.fromDocument(doc[STORY_CREATED_BY]);
    List<StoryPages> pages = [];

    if (doc[STORY_SCRIPT_PAGES]!.isNotEmpty) {
      doc[STORY_SCRIPT_PAGES].forEach((page) {
        StoryPages s = StoryPages.fromJson(page);
        pages.add(s);
      });
    }

    return Story(
        storyId: doc[STORY_ID],
        title: doc[STORY_TITLE],
        subtitle: doc[STORY_SUBTITLE] ?? "",
        photoUrl: doc[STORY_PHOTO_URL],
        createdBy: user,
        summary: doc[STORY_SUMMARY] ?? "No summary",
        category: doc[STORY_CATEGORY] ?? "Other",
        pages: pages,
        status: StoryStatus.values.byName(doc[STORY_STATUS]),
        likes: doc[ITEM_LIKES],
        mylikes: doc[ITEM_MY_LIKES],
        commentCount: doc[COMMENT_COUNT],
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt());
  }
}
