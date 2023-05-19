import 'package:machi_app/constants/constants.dart';

enum BotModelType { prompt, finetuning, textImage, imageText }

class BotCreatedBy {
  final String userId;
  final String username;
  final String photoUrl;

  BotCreatedBy(
      {required this.userId, required this.username, required this.photoUrl});

  factory BotCreatedBy.fromDocument(Map<String, dynamic> doc) {
    return BotCreatedBy(
        userId: doc[USER_ID],
        photoUrl: doc[BOT_PROFILE_PHOTO] ?? '',
        username: doc[USER_USERNAME]);
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
  final BotModelType modelType;
  final double? temperature;
  final bool? isActive;
  final bool? isPrivate;
  final String? adminStatus;
  final String? model;
  final String? profilePhoto;
  final String? adminNote;
  final BotCreatedBy? createdBy;
  final int? likes;
  final int? mylikes;
  final bool? isSubscribed;
  final int? subscribedAt;

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
      required this.modelType,
      this.temperature,
      this.isActive,
      this.isPrivate,
      this.adminStatus,
      this.model,
      this.adminNote,
      this.createdBy,
      this.likes,
      this.mylikes,
      this.isSubscribed,
      this.subscribedAt});

  Map<String, dynamic> toJson() => {
        'botId': botId,
        'profilePhoto': profilePhoto,
        'about': about,
        'name': name,
        'model': model,
        'modelType': modelType,
        'domain': domain,
        'subdomain': subdomain,
        'createdBy': createdBy,
        'isActive': isActive,
        'adminState': adminStatus,
        'adminNote': adminNote,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'prompt': prompt,
        'temperature': temperature,
        'likes': likes,
        'mylikes': mylikes,
        'isSubscribed': isSubscribed,
        'subscribedAt': subscribedAt
      };

  /// factory bot object
  factory Bot.fromDocument(Map<String, dynamic> doc) {
    BotCreatedBy createdBy = BotCreatedBy.fromDocument(doc[BOT_CREATED_BY]);
    return Bot(
        botId: doc[BOT_ID],
        profilePhoto: doc[BOT_PROFILE_PHOTO] ?? '',
        name: doc[BOT_NAME],
        model: doc[BOT_MODEL] ?? '',
        modelType: BotModelType.values.byName(doc[BOT_MODEL_TYPE]),
        subdomain: doc[BOT_SUBDOMAIN] ?? '',
        createdBy: createdBy,
        about: doc[BOT_ABOUT],
        domain: doc[BOT_DOMAIN] ?? '',
        isActive: doc[BOT_ACTIVE] ?? false,
        isPrivate: doc[BOT_IS_PRIVATE] ?? true,
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt(),
        adminStatus: doc[BOT_ADMIN_STATUS] ?? 'pending',
        adminNote: doc[BOT_ADMIN_NOTE] ?? "",
        prompt: doc[BOT_PROMPT] ?? '',
        temperature: doc[BOT_TEMPERATURE],
        likes: doc[ITEM_LIKES] == null ? 0 : doc[ITEM_LIKES]["likes"] ?? 0,
        mylikes: doc[ITEM_MY_LIKES] == null ? 0 : doc[ITEM_LIKES]["likes"] ?? 0,
        isSubscribed: doc[IS_SUBSCRIBED] ?? false,
        subscribedAt: doc[SUBSCRIBED_AT]);
  }
}
