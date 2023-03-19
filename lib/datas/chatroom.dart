import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class Chatroom {
  final String chatroomId;
  final String? title;
  final String? personality;
  final User? creatorUserId; // fb uid
  final String botId;
  final String hasMessages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chatroom({
    required this.chatroomId,
    this.creatorUserId,
    required this.botId,
    required this.createdAt,
    required this.updatedAt,
    required this.hasMessages,
    this.title,
    this.personality,
  });

  Map<String, dynamic> fromJson() => {
    'botId': botId,
    'title': title,
    'personality': personality,
    'botId': botId,
    'user': creatorUserId,
    'createdAt': createdAt,
    'updatedAt': updatedAt
  };

}