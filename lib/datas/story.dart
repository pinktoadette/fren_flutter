import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/storyboard.dart';

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
  final List<StoryPages>? pages;
  final int? createdAt;
  final int? updatedAt;

  Story(
      {required this.storyId,
      required this.title,
      required this.subtitle,
      required this.createdBy,
      required this.status,
      this.photoUrl,
      this.summary,
      required this.category,
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
        category: doc[STORY_CATEGORY] ?? "Other",
        pages: pages,
        status: StoryStatus.values.byName(doc[STORY_STATUS]),
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt());
  }
}
