import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationsApi {
  /// FINAL VARIABLES
  ///
  /// Firestore instance
  final _firestore = FirebaseFirestore.instance;

  /// Save notification in database
  Future<void> saveNotification({
    required String nReceiverId,
    required String nType,
    required String nMessage,
  }) async {
    _firestore.collection(C_NOTIFICATIONS).add({
      NOTIF_SENDER_ID: UserModel().user.userId,
      NOTIF_SENDER_USERNAME: UserModel().user.username,
      NOTIF_SENDER_PHOTO_LINK: UserModel().user.userProfilePhoto,
      NOTIF_RECEIVER_ID: nReceiverId,
      NOTIF_TYPE: nType,
      NOTIF_MESSAGE: nMessage,
      NOTIF_READ: false,
      CREATED_AT: FieldValue.serverTimestamp()
    }).then((_) {
      debugPrint('saveNotification() -> success');
    });
  }

  /// Notify Current User after purchasing VIP subscription
  Future<void> onPurchaseNotification({
    required String nMessage,
  }) async {
    _firestore.collection(C_NOTIFICATIONS).add({
      NOTIF_SENDER_USERNAME: APP_NAME,
      NOTIF_RECEIVER_ID: UserModel().user.userId,
      NOTIF_TYPE: 'alert',
      NOTIF_MESSAGE: nMessage,
      NOTIF_READ: false,
      CREATED_AT: FieldValue.serverTimestamp()
    }).then((_) {
      debugPrint('saveNotification() -> success');
    });
  }

  /// Get stream notifications for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotifications() {
    /// Build query
    return _firestore
        .collection(C_NOTIFICATIONS)
        .where(NOTIF_RECEIVER_ID, isEqualTo: UserModel().user.userId)
        // .orderBy(CREATED_AT, descending: true)
        .snapshots();
  }

  /// Delete current user notifications
  Future<void> deleteUserNotifications() async {
    await _firestore
        .collection(C_NOTIFICATIONS)
        .where(NOTIF_RECEIVER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      // Check result
      if (snapshot.docs.isEmpty) return;

      /// Loop notifications and delete one by one
      for (DocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        await doc.reference.delete();
      }

      debugPrint('deleteUserNotifications() -> deleted');
    });
  }

  Future<void> deleteUserSentNotifications() async {
    _firestore
        .collection(C_NOTIFICATIONS)
        .where(NOTIF_SENDER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      // Check result
      if (snapshot.docs.isEmpty) return;

      /// Loop notifications
      for (DocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        await doc.reference.delete();
      }
      debugPrint('deleteUserSentNotifications() -> deleted');
    });
  }

  /// Send push notification method
  Future<void> sendPushNotification({
    required String nTitle,
    required String nBody,
    required String nType,
    required String nSenderId,
    required String nUserDeviceToken,
    // Call Info Map Data
    Map<String, dynamic>? nCallInfo,
  }) async {
    // Variables
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    await http
        .post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${AppModel().appInfo.firebaseServerKey}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': nTitle,
            'body': nBody,
            'color': '#987dfa',
            'sound': "default"
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATIONOTIF_CLICK',
            NOTIF_TYPE: nType,
            NOTIF_SENDER_ID: nSenderId,
            'call_info': nCallInfo, // Call Info Data
            'status': 'done'
          },
          'to': nUserDeviceToken,
        },
      ),
    )
        .then((http.Response response) {
      if (response.statusCode == 200) {
        debugPrint('sendPushNotification() -> success');
      }
    }).catchError((error) {
      debugPrint('sendPushNotification() -> error: $error');
    });
  }
}
