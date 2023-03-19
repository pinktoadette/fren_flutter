import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

//@todo extend form types.Room
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

  factory Chatroom.fromJson(Map<String, dynamic> doc) {
    return Chatroom(
        chatroomId: doc['chatroomId'],
        botId: doc['botId'],
        title: doc['title'],
        personality: doc['personality'],
        creatorUserId: doc['creatorUserId'] ,
        createdAt: doc['createdAt'],
        updatedAt: doc['updatedAt'],
      hasMessages: doc['hasMessage'],
    );
  }


}