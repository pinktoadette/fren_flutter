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
  Future<Map<String, dynamic>> getBotIntroPrompt(String botId) async {
    final DocumentSnapshot<Map<String, dynamic>> botDoc =
        await BotModel().getBotIntro(botId);

    return botDoc.data()!;
  }

  /// Get stream messages for current user
  Stream<DocumentSnapshot<Map<String, dynamic>>> getBotIntro(String botId) {
    return _firestore
        .collection(C_BOT_INTRO)
        .doc(botId)
        .snapshots();
  }


}
