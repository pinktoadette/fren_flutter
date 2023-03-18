import 'package:firebase_auth/firebase_auth.dart';

class Chatroom {
  final String chatroomId;
  final String? title;
  final String? personality;
  final User creatorUserId; // fb uid
  final String botId;
  final String hasMessages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chatroom({
    required this.chatroomId,
    required this.creatorUserId,
    required this.botId,
    required this.createdAt,
    required this.updatedAt,
    required this.hasMessages,
    this.title,
    this.personality,
  });

}