import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/models/app_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fren_app/helpers/app_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/first_time_user.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fren_app/plugins/geoflutterfire/geoflutterfire.dart';
import 'package:place_picker/place_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

import '../datas/bot.dart';

class BotModel extends Model {
  /// Final Variables
  ///
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storageRef = FirebaseStorage.instance;
  final _fcm = FirebaseMessaging.instance;

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
  Future<DocumentSnapshot<Map<String, dynamic>>> getBot(String botId) async {
    return await _firestore.collection(C_BOT).doc(botId).get();
  }

  /// Get bot intro
  Future<DocumentSnapshot<Map<String, dynamic>>> getBotIntro(String botId) async {
    return await _firestore.collection(C_BOT_INTRO).doc(botId).get();
  }

  /// get matched bot
  Future<QuerySnapshot<Map<String, dynamic>>> getBotMatch(String botId, String userId) async {
    return await _firestore.collection(C_BOT_USER_MATCH)
        .where(BOT_ID, isEqualTo: botId)
        .where(USER_ID, isEqualTo: userId)
        .limit(1)
        .get();
  }

  // save the matched bot
  Future<DocumentReference<Map<String, dynamic>>> saveBotMatch(String botId) async {
    return await _firestore.collection(C_BOT_USER_MATCH).add({
      USER_ID:  UserModel().user.userId,
      BOT_ID: botId
    });
  }


}

