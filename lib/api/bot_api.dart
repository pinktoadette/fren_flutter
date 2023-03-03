import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/api/notifications_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/models/bot_model.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:flutter/material.dart';

import '../datas/bot.dart';

class BotApi {
  /// FINAL VARIABLES
  ///
  final _firestore = FirebaseFirestore.instance;

  // get Bot info
  Future<Bot> getBotInfo(String botId) async {
    final DocumentSnapshot<Map<String, dynamic>> botDoc =
        await BotModel().getBot(botId);

    /// return bot object
    return Bot.fromDocument(botDoc.data()!);
  }

  /// get bot introduction
  Future<List> getBotIntroPrompt(String botId) async {
    final DocumentSnapshot<Map<String, dynamic>> botDoc =
        await BotModel().getBotIntro(botId);
    // String<Array> data = botDoc.data()!.prompt;
    BotIntro a = BotIntro.fromDocument(botDoc.data()!);

    return a!.prompt;
  }

  /// Get stream messages for current user
  Stream<DocumentSnapshot<Map<String, dynamic>>> getBotIntro(String botId) {
    return _firestore.collection(C_BOT_INTRO).doc(botId).snapshots();
  }

  /// initialize start messages
  Future<QuerySnapshot<Map<String, dynamic>>> initalChatBot(
      String botId, String userId) async {
    QuerySnapshot<Map<String, dynamic>> botDoc =
        await BotModel().getBotMatch(botId, userId);

    if (botDoc.docs.isEmpty) {
      await BotModel().saveBotMatch(botId);
    }

    return botDoc;
  }

  /// Get stream messages for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserReplies(String userId) {
    return _firestore
        .collection(C_BOT_USER_MATCH)
        .doc(userId)
        .collection(DEFAULT_BOT_ID)
        .orderBy(TIMESTAMP)
        .snapshots();
  }
}
