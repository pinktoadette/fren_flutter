import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/api/notifications_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/dialogs/progress_dialog.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/helpers/app_notifications.dart';
import 'package:fren_app/widgets/custom_badge.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
// import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatelessWidget {
  // Variables
  final _notificationsApi = NotificationsApi();
  final _appNotifications = AppNotifications();

  NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    final pr = ProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate("notifications")),
        actions: [
          IconButton(
              icon: const Icon(Iconsax.trash),
              onPressed: () async {
                /// Delete all Notifications
                ///
                /// Show confirm dialog
                confirmDialog(context,
                    message:
                        i18n.translate("all_notifications_will_be_deleted"),
                    negativeAction: () => Navigator.of(context).pop(),
                    positiveText: i18n.translate("DELETE"),
                    positiveAction: () async {
                      // Show processing dialog
                      pr.show(i18n.translate("processing"));

                      /// Delete
                      await _notificationsApi.deleteUserNotifications();

                      // Hide progress dialog
                      pr.hide();
                      // Hide confirm dialog
                      Navigator.of(context).pop();
                    });
              })
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _notificationsApi.getNotifications(),
          builder: (context, snapshot) {
            /// Check data
            if (!snapshot.hasData) {
              return const Frankloader();
            } else if (snapshot.data!.docs.isEmpty) {
              /// No notification
              return Text(i18n.translate("no_notification"));
            } else {
              return ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) => const Divider(height: 10),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: ((context, index) {
                  /// Get notification DocumentSnapshot<Map<String, dynamic>>
                  final DocumentSnapshot<Map<String, dynamic>> notification =
                      snapshot.data!.docs[index];
                  final String? nType = notification[NOTIF_TYPE];
                  // Handle notification icon
                  late ImageProvider bgImage;
                  if (nType == 'alert') {
                    bgImage = const AssetImage('assets/images/app_logo.png');
                  } else {
                    bgImage =
                        NetworkImage(notification[NOTIF_SENDER_PHOTO_LINK]);
                  }

                  /// Show notification
                  return Container(
                    color: !notification[NOTIF_READ]
                        ? Theme.of(context).primaryColor.withAlpha(40)
                        : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage: bgImage,
                        onBackgroundImageError: (e, s) =>
                            {debugPrint(e.toString())},
                      ),
                      title: Text(
                          notification[NOTIF_TYPE] == 'alert'
                              ? notification[NOTIF_SENDER_FULLNAME]
                              : notification[NOTIF_SENDER_FULLNAME]
                                  .split(" ")[0],
                          style: const TextStyle(fontSize: 18)),
                      // subtitle: Text("${notification[NOTIF_MESSAGE]}\n"
                      //     "${timeago.format(notification[TIMESTAMP].toDate())}"),
                      trailing: !notification[NOTIF_READ]
                          ? CustomBadge(text: i18n.translate("new"))
                          : null,
                      onTap: () async {
                        /// Set notification read = true
                        await notification.reference.update({NOTIF_READ: true});

                        /// Handle notification click
                        _appNotifications.onNotificationClick(context,
                            nType: notification.data()?[NOTIF_TYPE] ?? '',
                            nSenderId:
                                notification.data()?[NOTIF_SENDER_ID] ?? '',
                            nMessage:
                                notification.data()?[NOTIF_MESSAGE] ?? '');
                      },
                    ),
                  );
                }),
              );
            }
          }),
    );
  }
}
