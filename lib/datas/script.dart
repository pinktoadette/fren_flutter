import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/storyboard.dart';

// ignore: constant_identifier_names
enum ScriptStatus { ACTIVE, INACTIVE, BLOCKED }

class ScriptImage {
  int size;
  int height;
  int width;
  String uri;
  ScriptImage(
      {required this.size,
      required this.height,
      required this.width,
      required this.uri});
  factory ScriptImage.fromDocumnet(Map<String, dynamic> doc) {
    return ScriptImage(
        size: doc[SCRIPT_IMAGE_SIZE].toInt(),
        height: doc[SCRIPT_IMAGE_HEIGHT].toInt(),
        width: doc[SCRIPT_IMAGE_WIDTH].toInt(),
        uri: doc[SCRIPT_IMAGE_URI]);
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      SCRIPT_IMAGE_SIZE: size,
      SCRIPT_IMAGE_HEIGHT: height,
      SCRIPT_IMAGE_WIDTH: width,
      SCRIPT_IMAGE_URI: uri
    };
  }
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
  final String? scriptId;
  final String? characterName;
  final StoryUser? createdBy;
  final String? type;
  final int? seqNum;
  final int? pageNum;
  final ScriptImage? image;
  final String? text;
  final Voiceover? voiceover;
  final String? status;
  final int? createdAt;
  final int? updatedAt;

  Script(
      {this.scriptId,
      this.characterName,
      this.createdBy,
      this.type,
      this.seqNum,
      this.pageNum,
      this.image,
      this.text,
      this.voiceover,
      this.status,
      this.createdAt,
      this.updatedAt});

  Script copyWith(
      {String? scriptId,
      StoryUser? createdBy,
      String? characterName,
      String? type,
      int? seqNum,
      int? pageNum,
      ScriptImage? image,
      String? text,
      Voiceover? voiceover,
      String? status}) {
    return Script(
        scriptId: scriptId ?? this.scriptId,
        createdBy: createdBy ?? this.createdBy,
        characterName: characterName ?? this.characterName,
        type: type ?? this.type,
        seqNum: seqNum ?? this.seqNum,
        pageNum: pageNum ?? this.pageNum,
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
      SCRIPT_PAGE_NUM: pageNum,
      SCRIPT_IMAGE: image != null ? image!.toJSON() : null,
      SCRIPT_SPEAKER_NAME: characterName,
      SCRIPT_VOICE_INFO: voiceover,
      SCRIPT_CREATED_BY: createdBy,
      SCRIPT_SEQUENCE_NUM: seqNum,
      CREATED_AT: createdAt,
      UPDATED_AT: updatedAt
    };
  }

  factory Script.fromJson(Map<String, dynamic> doc) {
    StoryUser? user;
    Voiceover? voiceover;
    ScriptImage? image;
    if (doc[SCRIPT_CREATED_BY] != null) {
      user = StoryUser.fromDocument(doc[SCRIPT_CREATED_BY]);
    }

    if (doc[SCRIPT_VOICE_INFO] != null) {
      voiceover = Voiceover.fromDocumnet(doc[SCRIPT_VOICE_INFO]);
    }

    if (doc[SCRIPT_IMAGE] != null) {
      image = ScriptImage.fromDocumnet(doc[SCRIPT_IMAGE]);
    }

    return Script(
        scriptId: doc[SCRIPT_ID],
        type: doc[SCRIPT_TYPE],
        text: doc[SCRIPT_TEXT],
        image: image,
        createdBy: user,
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt(),
        voiceover: voiceover,
        characterName: doc[SCRIPT_SPEAKER_NAME],
        seqNum: doc[SCRIPT_SEQUENCE_NUM],
        pageNum: doc[SCRIPT_PAGE_NUM],
        status: doc[SCRIPT_STATUS]);
  }
}
