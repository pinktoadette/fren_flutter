import 'package:fren_app/constants/constants.dart';

class BotPrompt {
  final String text;
  final int wait;
  final String? selection;
  final bool hasNext;

  BotPrompt(
      {required this.text,
      required this.wait,
      required this.selection,
      required this.hasNext});

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
  final String about;
  final String name;
  final String domain;
  final String subdomain;
  final int createdAt;
  final int updatedAt;
  final String prompt;
  final double temperature;
  final bool? isActive;
  final String? adminStatus;
  final String? model;
  final String? profilePhoto;
  final String? adminNote;
  final double? price;
  final String? priceUnit;
  final Object? botOwnerId;

  // Constructor
  Bot(
      {required this.botId,
      required this.profilePhoto,
      required this.name,
      required this.domain,
      required this.subdomain,
      required this.createdAt,
      required this.about,
      required this.updatedAt,
      required this.prompt,
      required this.temperature,
      this.isActive,
      this.adminStatus,
      this.model,
      this.adminNote,
      this.price,
      this.priceUnit,
      this.botOwnerId});

  Map<String, dynamic> toJson() => {
        'botId': botId,
        'profilePhoto': profilePhoto,
        'about': about,
        'name': name,
        'model': model,
        'domain': domain,
        'subdomain': subdomain,
        'price': price,
        'priceUnit': priceUnit,
        'botOwnerId': botOwnerId,
        'isActive': isActive,
        'adminState': adminStatus,
        'adminNote': adminNote,
        'createdAt': createdAt,
        'updatedAt': updatedAt
      };

  /// factory bot object
  factory Bot.fromDocument(Map<String, dynamic> doc) {
    return Bot(
      botId: doc[BOT_ID],
      profilePhoto: doc[BOT_PROFILE_PHOTO] ?? '',
      name: doc[BOT_NAME],
      model: doc[BOT_MODEL] ?? '',
      subdomain: doc[BOT_SUBDOMAIN] ?? '',
      botOwnerId: doc[BOT_OWNER_ID],
      about: doc[BOT_ABOUT],
      domain: doc[BOT_DOMAIN],
      isActive: doc[BOT_ACTIVE] ?? false,
      prompt: doc[BOT_PROMPT],
      temperature: doc[BOT_TEMPERATURE] ?? 0.5,
      createdAt: doc[CREATED_AT],
      updatedAt: doc[UPDATED_AT],
      adminStatus: doc[BOT_ADMIN_STATUS] ?? 'pending',
      adminNote: doc[BOT_ADMIN_NOTE] ?? "",
    );
  }
}
