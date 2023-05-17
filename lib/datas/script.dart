import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/storyboard.dart';

class Image {
  int size;
  int height;
  int width;
  String uri;
  Image(
      {required this.size,
      required this.height,
      required this.width,
      required this.uri});
}

class Voiceover {
  String id;
  String provider;
  String voiceName;
  String jsonData;
  Voiceover(
      {required this.id,
      required this.provider,
      required this.voiceName,
      required this.jsonData});
  factory Voiceover.fromDocumnet(Map<String, dynamic> doc) {
    return Voiceover(
        id: doc[VOICE_OVER_ID],
        provider: doc[VOICE_PROVIDER],
        voiceName: doc[VOICE_NAME],
        jsonData: doc[VOICE_JSON]);
  }
}

class Script {
  final String scriptId;
  final String characterName;
  final StoryUser createdBy;
  final String type;
  final int seqNum;
  final Image? image;
  final String? text;
  final Voiceover? voiceover;
  final String? status;
  final int? createdAt;
  final int? updatedAt;

  Script(
      {required this.scriptId,
      required this.characterName,
      required this.createdBy,
      required this.type,
      required this.seqNum,
      this.image,
      this.text,
      this.voiceover,
      required this.status,
      this.createdAt,
      this.updatedAt});

  Script copyWith(
      {String? scriptId,
      StoryUser? createdBy,
      String? characterName,
      String? type,
      int? seqNum,
      Image? image,
      String? text,
      Voiceover? voiceover,
      String? status}) {
    return Script(
        scriptId: scriptId ?? this.scriptId,
        createdBy: createdBy ?? this.createdBy,
        characterName: characterName ?? this.characterName,
        type: type ?? this.type,
        seqNum: seqNum ?? this.seqNum,
        image: image ?? this.image,
        text: text ?? this.text,
        voiceover: voiceover ?? this.voiceover,
        status: '');
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      SCRIPT_ID: scriptId,
      SCRIPT_TYPE: type,
      SCRIPT_TEXT: text,
      SCRIPT_IMAGE: image,
      SCRIPT_SPEAKER_NAME: characterName,
      SCRIPT_VOICE_INFO: voiceover,
      SCRIPT_CREATED_BY: createdBy,
      SCRIPT_SEQUENCE_NUM: seqNum,
      CREATED_AT: createdAt,
      UPDATED_AT: updatedAt
    };
  }

  factory Script.fromJson(Map<String, dynamic> doc) {
    StoryUser user = StoryUser.fromDocument(doc[SCRIPT_CREATED_BY]);
    Voiceover voiceover = Voiceover.fromDocumnet(doc[SCRIPT_VOICE_INFO]);
    return Script(
        scriptId: doc[STORY_ID],
        type: doc[STORY_TITLE],
        text: doc[STORY_SUBTITLE],
        image: doc[STORY_PHOTO_URL],
        createdBy: user,
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt(),
        voiceover: voiceover,
        characterName: doc[SCRIPT_SPEAKER_NAME],
        seqNum: doc[SCRIPT_SEQUENCE_NUM],
        status: doc[SCRIPT_STATUS]);
  }
}
