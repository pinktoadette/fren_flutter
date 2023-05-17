import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/storyboard.dart';

class Story {
  final String storyId;
  final String title;
  final String subtitle;
  final StoryUser createdBy;
  final StoryStatus status;
  final String? photoUrl;
  final String category;
  final List<Script>? scripts;
  final int? createdAt;
  final int? updatedAt;

  Story(
      {required this.storyId,
      required this.title,
      required this.subtitle,
      required this.createdBy,
      required this.status,
      this.photoUrl,
      required this.category,
      this.scripts,
      this.createdAt,
      this.updatedAt});

  Story copyWith({
    String? storyId,
    String? title,
    String? subtitle,
    StoryUser? createdBy,
    StoryStatus? status,
    List<Script>? scripts,
    String? photoUrl,
    String? category,
  }) {
    return Story(
        storyId: storyId ?? this.storyId,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        createdBy: createdBy ?? this.createdBy,
        status: status ?? this.status,
        scripts: scripts ?? this.scripts,
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
      BOT_CREATED_BY: createdBy,
      CREATED_AT: createdAt,
      UPDATED_AT: updatedAt,
    };
  }

  factory Story.fromJson(Map<String, dynamic> doc) {
    StoryUser user = StoryUser.fromDocument(doc[STORY_CREATED_BY]);
    List<Script> scripts = [];

    if (doc[SCRIPTS].isNotEmpty) {
      doc[SCRIPTS].forEach((script) {
        Script s = Script.fromJson(script);
        scripts.add(s);
      });
    }

    return Story(
        storyId: doc[STORY_ID],
        title: doc[STORY_TITLE],
        subtitle: doc[STORY_SUBTITLE] ?? "",
        photoUrl: doc[STORY_PHOTO_URL],
        createdBy: user,
        category: doc[STORY_CATEGORY] ?? "Other",
        scripts: scripts,
        status: StoryStatus.values.byName(doc[STORY_STATUS]),
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt());
  }
}
