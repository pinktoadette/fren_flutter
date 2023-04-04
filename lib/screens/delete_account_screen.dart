import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/api/blocked_users_api.dart';
import 'package:fren_app/api/conversations_api.dart';
import 'package:fren_app/api/matches_api.dart';
import 'package:fren_app/api/messages_api.dart';
import 'package:fren_app/api/notifications_api.dart';
import 'package:fren_app/api/visits_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/sign_in_screen.dart';
import 'package:fren_app/widgets/processing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  // Variables
  final _firestore = FirebaseFirestore.instance;
  final _storageRef = FirebaseStorage.instance;

  /// Api instances
  final _notificationsApi = NotificationsApi();
  final _conversationsApi = ConversationsApi();
  final _messagesApi = MessagesApi();
  final _matchesApi = MatchesApi();
  final _visitsApi = VisitsApi();

  /// DELETE USER ACCOUNT
  ///
  Future<void> _deleteUserAccount() async {
    ///
    /// DELETE ALL USER TRANSACTIONS FROM DATABASE AND STORAGE
    ///
    /// DELETE CURRENT USER PROFILE
    await _firestore.collection(C_USERS).doc(UserModel().user.userId).delete();
    debugPrint('Profile account -> deleted...');

    // Get user uploaded profile image links
    final List<String> _userImagesRef =
        UserModel().getUserProfileImages(UserModel().user);

    /// DELETE PROFILE IMAGE AND GALLERY
    ///
    /// Loop user profile images to be deleted from storage
    for (var imgUrl in _userImagesRef) {
      // Delete profile image and gallery
      await _storageRef.refFromURL(imgUrl).delete();
    }
    debugPrint('Profile images -> deleted...');

    /// DELETE USER MATCHES
    ///
    // Get user matches
    final List<DocumentSnapshot<Map<String, dynamic>>> _matches =
        await _matchesApi.getMatches();
    // Check matches
    if (_matches.isNotEmpty) {
      // Loop matches to be deleted
      for (var match in _matches) {
        await _matchesApi.deleteMatch(match.id);
      }
    }
    debugPrint('Matches -> deleted...');

    /// DELETE USER CONVERSATIONS AND CHAT MESSAGES
    ///
    /// Get user conversations
    final List<DocumentSnapshot<Map<String, dynamic>>> _conversations =
        (await _conversationsApi.getConversations().first).docs;
    // Check conversations
    if (_conversations.isNotEmpty) {
      // Loop conversations to be deleted
      for (var converse in _conversations) {
        await _conversationsApi.deleteConverce(converse.id, isDoubleDel: true);
        // Delete chat for current user and for other users
        await _messagesApi.deleteChat(converse.id, isDoubleDel: true);
      }
    }
    debugPrint('Conversations -> deleted...');

    /// DELETE VISITED USERS
    await _visitsApi.deleteVisitedUsers();

    /// DELETE NOTIFICATIONS RECEIVED BY USER
    ///
    await _notificationsApi.deleteUserNotifications();

    /// DELETE NOTIFICATIONS SENT BY USER
    ///
    await _notificationsApi.deleteUserSentNotifications();

    /// DELETE BLOCKED USERS TO FREE THE STORAGE SPACE
    ///
    await BlockedUsersApi().deleteBlockedUsers();
  }

  @override
  void initState() {
    super.initState();
    // Start deleting user account
    _deleteUserAccount().then((_) {
      // Log out and go to sign in screen
      UserModel().signOut().then((_) {
        Future(() {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const SignInScreen()));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      body: Processing(
        text: i18n.translate("deleting_your_account"),
      ),
    );
  }
}
