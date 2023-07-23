import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';

extension ListExtensions<T> on List<T> {
  T? firstOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

class StoryComment {
  String comment;
  String? commentId;
  int createdAt;
  int updatedAt;
  StoryUser user;
  int? likes;
  int? mylikes;
  List<StoryComment>? response;

  StoryComment(
      {required this.comment,
      required this.createdAt,
      required this.updatedAt,
      required this.user,
      this.commentId,
      this.likes,
      this.mylikes,
      this.response});

  factory StoryComment.fromDocument(Map<String, dynamic> doc) {
    StoryUser user = StoryUser.fromDocument(doc["user"]);
    List<StoryComment> responses = [];

    if (doc[COMMENT_RESPONSES] != null) {
      for (int i = 0; i < doc[COMMENT_RESPONSES].length; i++) {
        StoryComment comment =
            StoryComment.fromDocument(doc[COMMENT_RESPONSES][i]);
        responses.add(comment);
      }
    }

    return StoryComment(
        comment: doc[STORY_COMMENT],
        user: user,
        commentId: doc[COMMENT_ID],
        likes: doc[ITEM_LIKES],
        mylikes: doc[ITEM_MY_LIKES],
        createdAt: doc[CREATED_AT],
        updatedAt: doc[UPDATED_AT],
        response: responses);
  }
}

class StoryPages {
  final List<Script>? scripts;
  final int? pageNum;
  String? backgroundImageUrl;
  double? backgroundAlpha;
  StoryPages(
      {this.scripts,
      this.pageNum,
      this.backgroundImageUrl,
      this.backgroundAlpha});

  factory StoryPages.fromJson(Map<String, dynamic> doc) {
    List<Script> scripts = [];

    if (doc[SCRIPTS].isNotEmpty) {
      doc[SCRIPTS].forEach((page) {
        Script s = Script.fromJson(page);
        scripts.add(s);
      });
    }
    StoryPages pages = StoryPages(
      pageNum: doc[SCRIPT_PAGE_NUM],
      scripts: scripts,
    );
    return pages;
  }

  StoryPages copyWith(
      {List<Script>? scripts,
      int? pageNum,
      String? backgroundImageUrl,
      double? backgroundAlpha}) {
    return StoryPages(
        pageNum: pageNum ?? this.pageNum,
        scripts: scripts ?? this.scripts,
        backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
        backgroundAlpha: backgroundAlpha ?? this.backgroundAlpha);
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
  Layout? layout;
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
      this.layout,
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
      Layout? layout,
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
        layout: layout ?? this.layout,
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
      STORY_LAYOUT: layout,
      BOT_CREATED_BY: createdBy,
      ITEM_MY_LIKES: mylikes,
      ITEM_LIKES: likes,
      CREATED_AT: createdAt,
      UPDATED_AT: updatedAt
    };
  }

  factory Story.fromJson(Map<String, dynamic> doc) {
    StoryUser user = StoryUser.fromDocument(doc[STORY_CREATED_BY]);
    List<StoryPages> pages = [];

    if (doc[STORY_SCRIPT_PAGES]!.isNotEmpty) {
      doc[STORY_SCRIPT_PAGES].forEach((page) {
        StoryPages s = StoryPages.fromJson(page);
        List<dynamic> coverPages = doc[STORY_COVER_PAGES] ?? [];
        if (coverPages.isNotEmpty) {
          String? background;

          Map<String, dynamic>? item = coverPages.firstWhere(
              (page) => page["pageNum"] == s.pageNum,
              orElse: () => null);
          background = item?[STORY_PAGES_BACKGROUND];
          if (background != null) {
            s = s.copyWith(
                backgroundImageUrl: background,
                backgroundAlpha: item?[STORY_PAGES_ALPHA] ?? 0.8);
          }
        }
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
        layout: doc[STORY_LAYOUT] != null
            ? Layout.values.byName(doc[STORY_LAYOUT])
            : Layout.CONVO,
        pages: pages,
        status: StoryStatus.values.byName(doc[STORY_STATUS]),
        likes: doc[ITEM_LIKES],
        mylikes: doc[ITEM_MY_LIKES],
        commentCount: doc[COMMENT_COUNT],
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt());
  }
}
