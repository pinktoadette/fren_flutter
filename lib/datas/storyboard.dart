import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/constants/constants.dart';

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

/// Sequence, SceneId, types.Message
class Scene {
  final int seq;
  final String sceneId;
  final types.Message messages;

  Scene({required this.seq, required this.sceneId, required this.messages});

  Scene copyWith({int? seq, String? sceneId, types.Message? messages}) {
    return Scene(
        seq: seq ?? this.seq,
        sceneId: sceneId ?? this.sceneId,
        messages: messages ?? this.messages);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> message = messages.toJson();
    return <String, dynamic>{
      'seq': seq,
      'sceneId': sceneId,
      'message': message
    };
  }
}

class Storyboard {
  /// Using types and Chatroom together
  final String title;
  final String storyboardId;

  final List<Scene>? scene;
  final StoryUser createdBy;
  final int createdAt;
  final int updatedAt;
  final StoryStatus status;
  final bool? showNames;

  Storyboard(
      {required this.title,
      required this.scene,
      required this.storyboardId,
      required this.createdBy,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      required this.showNames});

  Storyboard copyWith(
      {String? title,
      List<Scene>? scene,
      StoryUser? createdBy,
      String? storyboardId,
      StoryStatus? status,
      int? createdAt,
      int? updatedAt,
      bool? showNames}) {
    return Storyboard(
        title: title ?? this.title,
        scene: scene ?? this.scene,
        storyboardId: storyboardId ?? this.storyboardId,
        createdBy: createdBy ?? this.createdBy,
        status: status ?? this.status,
        showNames: showNames ?? this.showNames,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt);
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'title': title,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'scene': scene,
      'status': status,
      'storyboardId': storyboardId,
      'createdBy': createdBy,
      'showNames': showNames
    };
  }

  factory Storyboard.fromJson(Map<String, dynamic> doc) {
    /// get Bot

    StoryUser user = StoryUser.fromDocument(doc[STORY_CREATED_BY]);

    /// convert messages to scene with types.Messages as messages
    List<Scene> listScene = [];
    if (doc[STORY_SCENE][0][STORY_MESSAGES].isNotEmpty) {
      late Scene detailScene;
      doc[STORY_SCENE].forEach((scene) {
        var message = scene[STORY_MESSAGES];
        types.Message finalMessage;
        final author = types.User(
            id: message[CHAT_AUTHOR_ID] as String,
            firstName: message[CHAT_USER_NAME] ?? "Frankie",
            metadata: message[CHAT_AUTHOR_ID].contains("Machi_")
                ? {"showMeta": true}
                : null);
        message[CHAT_AUTHOR] = author.toJson();
        message[FLUTTER_UI_ID] = message[CHAT_MESSAGE_ID];
        message[CREATED_AT] = message[CREATED_AT]?.toInt();

        if (message[CHAT_TYPE] == CHAT_IMAGE) {
          message['size'] = message[MESSAGE_IMAGE][MESSAGE_IMAGE_SIZE];
          message['height'] = message[MESSAGE_IMAGE][MESSAGE_IMAGE_HEIGHT];
          message['width'] = message[MESSAGE_IMAGE][MESSAGE_IMAGE_WIDTH];
          message['uri'] = message[MESSAGE_IMAGE][MESSAGE_IMAGE_URI];
          finalMessage = types.ImageMessage.fromJson(message);
        } else {
          finalMessage = types.Message.fromJson(message);
        }
        detailScene = Scene(
            seq: scene[STORY_SCENE_SEQ],
            sceneId: scene[STORY_SCENE_ID],
            messages: finalMessage);
        listScene.add(detailScene);
      });
    }

    return Storyboard(
        title: doc[STORY_TITLE],
        createdBy: user,
        scene: listScene,
        storyboardId: doc[STORY_ID],
        status: StoryStatus.values.byName(doc[STORY_STATUS]),
        showNames: doc[STORY_SHOW_NAMES] ?? false,
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt());
  }
}
