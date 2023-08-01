import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/api/notifications_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/app_notifications.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/screens/storyboard/page_view.dart';
import 'package:machi_app/screens/user/profile_screen.dart';
import 'package:machi_app/widgets/common/avatar_initials.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/widgets/common/no_data.dart';

import '../models/user_model.dart';

class NotificationsScreen extends StatelessWidget {
  // Variables
  final _notificationsApi = NotificationsApi();
  final _appNotifications = AppNotifications();

  NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          i18n.translate("notifications"),
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _notificationsApi.getNotifications(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return NoData(text: i18n.translate("no_notification"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final notification = snapshot.data!.docs[index];
                final notifType = notification[NOTIF_TYPE];
                final notifRead = notification[NOTIF_READ];
                final createdAt = formatDate(notification[CREATED_AT]);

                return NotificationListItem(
                  notification: notification,
                  notifType: notifType,
                  notifRead: notifRead,
                  createdAt: createdAt,
                  onTap: () => _onNotificationTap(context, notification),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _onNotificationTap(BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> notification) async {
    /// Set notification read = true
    await notification.reference.update({NOTIF_READ: true});

    final notifType = notification[NOTIF_TYPE];
    final notifSenderId = notification[NOTIF_SENDER_ID];
    final notifMessage = notification[NOTIF_MESSAGE];

    if (notifType == "REQUEST" || notifType == "FOLLOWING") {
      final User user = await UserModel().getUserObject(notifSenderId);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProfileScreen(user: user)));
    } else if (notifType.contains("COMMENT")) {
      final _storyApi = StoryApi();
      Story story = await _storyApi.getMyStories(notification["itemId"]);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => StoryPageView(story: story)));
    }

    /// Handle notification click
    _appNotifications.onNotificationClick(
      context,
      nType: notifType,
      nSenderId: notifSenderId,
      nMessage: notifMessage,
    );
  }
}

class NotificationListItem extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> notification;
  final String notifType;
  final bool notifRead;
  final String createdAt;
  final VoidCallback onTap;

  NotificationListItem({
    required this.notification,
    required this.notifType,
    required this.notifRead,
    required this.createdAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: InkWell(
        onTap: onTap,
        child: AvatarInitials(
          radius: 20,
          userId: notification[NOTIF_SENDER_ID],
          photoUrl: notification[NOTIF_SENDER_PHOTO_LINK] ?? "",
          username: notification[NOTIF_SENDER_USERNAME],
        ),
      ),
      title: Row(
        children: [
          Text(
            notification[NOTIF_SENDER_USERNAME],
            style: !notifRead
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            createdAt,
            style: !notifRead
                ? Theme.of(context).textTheme.bodyMedium
                : Theme.of(context).textTheme.labelSmall,
          ),
          if (!notifRead)
            const Icon(Iconsax.info_circle1, size: 14, color: APP_ACCENT_COLOR),
        ],
      ),
      subtitle: Text(
        notification[NOTIF_MESSAGE],
        style: !notifRead
            ? Theme.of(context).textTheme.bodySmall
            : Theme.of(context).textTheme.labelSmall,
      ),
      onTap: onTap,
    );
  }
}
