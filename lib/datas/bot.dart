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
        wait: doc['wait'] as int,
        selection: doc['selection'],
        hasNext: doc['hasNext'] as bool,
    );
  }
}

class Bot {
  /// Bot info
  final String botId;
  final String? profilePhoto;
  final String name;
  final String model;
  final String repoId;
  final String domain;
  final String subdomain;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String adminStatus;
  final String? adminNote;
  final double? price;
  final Object? botOwnerId;
  final String? about;

  // Constructor
  Bot({
    required this.botId,
    required this.profilePhoto,
    required this.name,
    required this.model,
    required this.domain,
    required this.repoId,
    required this.subdomain,
    required this.createdAt,
    required this.isActive,
    required this.adminStatus,
    required this.updatedAt,
    this.adminNote,
    this.price,
    this.botOwnerId,
    this.about
  });

  Map<String, dynamic> toJson() => {
    'botId': botId,
    'profilePhoto': profilePhoto,
    'name': name,
    'model': model,
    'domain': domain,
    'subdomain': subdomain,
    'repoId': repoId,
    'regDate': createdAt,
    'isActive': isActive,
    'adminState': adminStatus,
    'updatedAt': updatedAt,
    'adminNote': adminNote,
    'price': price,
    'botOwnerId': botOwnerId,
    'about': about
  };

  /// factory bot object
  factory Bot.fromDocument(Map<String, dynamic> doc) {
    return Bot(
      botId: doc[BOT_ID],
      profilePhoto: doc[BOT_PROFILE_PHOTO] ?? '',
      name: doc[BOT_NAME],
      model: doc[BOT_MODEL] ?? '',
      repoId: doc[BOT_REPO_ID] ?? '',
      price: doc[BOT_PRICE] ?? 0,
      subdomain: doc[BOT_SUBDOMAIN] ?? '',
      botOwnerId: doc[BOT_OWNER_ID],
      about: doc[BOT_ABOUT],
      domain: doc[BOT_DOMAIN],
      isActive: doc[BOT_ACTIVE] ?? false,
      createdAt: doc[CREATED_AT].toDate(),
      updatedAt: doc[UPDATED_AT].toDate(),
      adminStatus: doc[BOT_ADMIN_STATUS] ?? 'pending',
      adminNote: doc[BOT_ADMIN_NOTE] ?? "",
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