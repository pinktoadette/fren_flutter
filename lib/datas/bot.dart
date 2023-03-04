import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/user.dart';


class BotPrompt {
  final String text;
  final int wait;
  final String? selection;
  final bool hasNext;

  BotPrompt({
    required this.text,
    required this.wait,
    required this.selection,
    required this.hasNext
  });

  factory BotPrompt.fromJson(Map<String, dynamic> doc) {
    return BotPrompt(
        text: doc['text'],
        wait: doc['wait'],
        selection: doc['selection'],
        hasNext: doc['hasNext'],
    );
  }
}

class Bot {
  /// Bot info
  final String botId;
  final String profilePhoto;
  final String name;
  final String model;
  final String specialty;
  final DateTime botRegDate;
  final Object? botOwnerId;
  final String? huggingFaceModel;
  final String? apiUrlModel;
  final String? about;

  // Constructor
  Bot({
    required this.botId,
    required this.profilePhoto,
    required this.name,
    required this.model,
    required this.specialty,
    required this.botRegDate,
    this.botOwnerId,
    this.huggingFaceModel,
    this.apiUrlModel,
    this.about
  });

  /// factory bot object
  factory Bot.fromDocument(Map<String, dynamic> doc) {
    return Bot(
      botId: doc[BOT_ID],
      profilePhoto: doc[BOT_PROFILE_PHOTO],
      name: doc[BOT_NAME],
      model: doc[BOT_MODEL],
      specialty: doc[BOT_SPECIALTY],
      botRegDate: doc[BOT_REG_DATE].toDate(),
      botOwnerId: doc[BOT_OWNER_ID],
      huggingFaceModel: doc[BOT_HUGGING_FACE_MODEL],
      apiUrlModel: doc[BOT_MODEL_API_URL],
      about: doc[BOT_ABOUT]
    );
  }
}

class BotIntro {
  final List prompt;

  BotIntro({
    required this.prompt
  });

  factory BotIntro.fromDocument(Map<String, dynamic> doc) {
    return BotIntro(
      prompt: doc['prompt'],
    );
  }
}