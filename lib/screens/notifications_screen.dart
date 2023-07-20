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
        title: Text(i18n.translate("notifications"),
            style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _notificationsApi.getNotifications(),
          builder: (context, snapshot) {
            /// Check data
            if (!snapshot.hasData) {
              return NoData(text: i18n.translate("no_notification"));
            } else {
              return ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) => const Divider(height: 10),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: ((context, index) {
                  /// Get notification DocumentSnapshot<Map<String, dynamic>>
                  final DocumentSnapshot<Map<String, dynamic>> notification =
                      snapshot.data!.docs[index];

                  /// Show notification
                  return ListTile(
                    leading: InkWell(
                        onTap: () async {
                          final User user = await UserModel()
                              .getUserObject(notification[NOTIF_SENDER_ID]);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ProfileScreen(user: user)));
                        },
                        child: AvatarInitials(
                          radius: 20,
                          userId: notification[NOTIF_SENDER_ID],
                          photoUrl: notification[NOTIF_SENDER_PHOTO_LINK],
                          username: notification[NOTIF_SENDER_USERNAME],
                        )),
                    title: Row(children: [
                      Text(notification[NOTIF_SENDER_USERNAME],
                          style: !notification[NOTIF_READ]
                              ? Theme.of(context).textTheme.titleMedium
                              : Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      Text(formatDate(notification[CREATED_AT]),
                          style: !notification[NOTIF_READ]
                              ? Theme.of(context).textTheme.bodyMedium
                              : Theme.of(context).textTheme.labelSmall),
                      !notification[NOTIF_READ]
                          ? const Icon(Iconsax.info_circle1,
                              size: 14, color: APP_ACCENT_COLOR)
                          : const SizedBox(
                              width: 15,
                              height: 15,
                            )
                    ]),
                    subtitle: Text(notification[NOTIF_MESSAGE],
                        style: !notification[NOTIF_READ]
                            ? Theme.of(context).textTheme.bodySmall
                            : Theme.of(context).textTheme.labelSmall),
                    onTap: () async {
                      /// Set notification read = true
                      await notification.reference.update({NOTIF_READ: true});
                      if (notification[NOTIF_TYPE] == "REQUEST" ||
                          notification[NOTIF_TYPE] == "FOLLOWING") {
                        final User user = await UserModel()
                            .getUserObject(notification[NOTIF_SENDER_ID]);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfileScreen(user: user)));
                      }

                      if (notification[NOTIF_TYPE] == "COMMENT") {
                        final _storyApi = StoryApi();
                        Story story = await _storyApi
                            .getMyStories(notification["itemId"]);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => StoryPageView(story: story)));
                      }

                      /// Handle notification click
                      _appNotifications.onNotificationClick(context,
                          nType: notification.data()?[NOTIF_TYPE] ?? '',
                          nSenderId:
                              notification.data()?[NOTIF_SENDER_ID] ?? '',
                          nMessage: notification.data()?[NOTIF_MESSAGE] ?? '');
                    },
                  );
                }),
              );
            }
          }),
    );
  }
}
