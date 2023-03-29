import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/models/bot_model.dart';
import 'package:fren_app/models/user_model.dart';

import '../datas/bot.dart';

class BotApi {
  /// FINAL VARIABLES
  ///
  final _firestore = FirebaseFirestore.instance;

  /// get Bot info
  Future<Bot> getBotInfo(String botId) async {
    final DocumentSnapshot<Map<String, dynamic>> botDoc =
        await BotModel().getBot(botId);

    /// return bot object
    return Bot.fromDocument(botDoc.data()!);
  }

  /// get inital frankie
  Future getInitialFrankie() async {
    QuerySnapshot<Map<String, dynamic>> data =
        await _firestore.collection(C_BOT_WALKTHRU).orderBy('sequence').get();
    List steps = [];
    for (var element in data.docs) {
      final ele = element.data();
      steps.add(ele);
    }
    return steps;
  }

  /// initialize start messages
  Future<QuerySnapshot<Map<String, dynamic>>> botMatch(
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

  Future<void> tryBot(Bot bot) async {
    var query = await _firestore
        .collection(C_BOT_TRIALS)
        .doc(UserModel().user.userId)
        .collection(bot.botId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      await _firestore
          .collection(C_BOT_TRIALS)
          .doc(UserModel().user.userId)
          .collection(bot.botId)
          .add({
        BOT_TRIAL_BOT_ID: bot.botId,
        BOT_TRIAL_OWNER_ID: UserModel().user.userId,
        BOT_TRIAL_TIMES: 0
      });
    } else {}
  }
}
