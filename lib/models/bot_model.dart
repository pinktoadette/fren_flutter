import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/sqlite/db.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:fren_app/constants/constants.dart';

import '../datas/bot.dart';

class BotModel extends Model {
  /// Final Variables
  ///
  final _firestore = FirebaseFirestore.instance;

  /// Other variables
  ///
  late Bot bot;
  bool isLoading = false;

  static final BotModel _botModel = BotModel._internal();
  factory BotModel() {
    return _botModel;
  }
  BotModel._internal();

  /// Get bot info from database => [DocumentSnapshot<Map<String, dynamic>>]
  /// Original from fb, now get from localdb
  Future<DocumentSnapshot<Map<String, dynamic>>> getBot(String botId) async {
    return await _firestore.collection(C_BOT).doc(botId).get();
  }

  /// get matched bot
  Future<QuerySnapshot<Map<String, dynamic>>> getBotMatch(String botId, String userId) async {
    return await _firestore.collection(C_BOT_USER_MATCH)
        .where(BOT_ID, isEqualTo: botId)
        .where(USER_ID, isEqualTo: userId)
        .limit(1)
        .get();
  }

  /// Get bot object => [Bot]
  Future<Bot> getBotObject(String botId) async {
    final DocumentSnapshot<Map<String, dynamic>> botDoc =
      await BotModel().getBot(botId);

    return Bot.fromDocument({...botDoc.data()!, BOT_ID: botId });
  }

  /// save the matched bot
  Future<DocumentReference<Map<String, dynamic>>> saveBotMatch(String botId) async {
    return await _firestore.collection(C_BOT_USER_MATCH).add({
      USER_ID:  UserModel().user.userId,
      BOT_ID: botId
    });
  }

  /// update bot
  Future<void> updateBotData({
    required String botId,
    required Map<String, dynamic> data,
    required VoidCallback onSuccess,
    required Function(String errorType) onError,
  }) async {
    _firestore.collection(C_BOT).doc(botId).update(data).then((bot) async{
      onSuccess();
    }).catchError((onError) {
      debugPrint('createBot() -> error');
      // Callback function
      onError(onError);
    });
  }

  /// get bot created
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getMyCreatedBot() async {
    final QuerySnapshot<Map<String, dynamic>> query = await _firestore
        .collection(C_BOT)
        .where(BOT_OWNER_ID, isEqualTo: UserModel().user.userId)
        .get();
    return query.docs;
  }

  /// get all bots created @todo trending bots
  /// need number of clicks
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllBotsTrend() async {
    final QuerySnapshot<Map<String, dynamic>> query = await _firestore
        .collection(C_BOT)
        .get();
    return query.docs;
  }

  /// create bot
  Future<void> createBot({
    required ownerId,
    required name,
    required domain,
    required subdomain,
    required repoId,
    required price,
    required about,
    required ValueSetter onSuccess,
    required Function(String) onError,
  }) async {
    _firestore
        .collection(C_BOT)
        .add(<String, dynamic> {
          BOT_OWNER_ID: ownerId,
          BOT_NAME: name,
          BOT_DOMAIN: domain,
          BOT_SUBDOMAIN: subdomain,
          BOT_REPO_ID: repoId,
          BOT_ABOUT: about,
          BOT_ACTIVE: false,
          BOT_ADMIN_STATUS: 'pending',
          CREATED_AT: FieldValue.serverTimestamp(),
          UPDATED_AT: FieldValue.serverTimestamp(),
          BOT_PRICE: double.parse(price),
        })
        .then((bot) async{


          onSuccess(bot.id);
    }).catchError((onError) {
      debugPrint('createBot() -> error');
      // Callback function
      onError(onError);
    });
  }


}

