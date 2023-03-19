import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/controller/chat_controller.dart';
import 'package:fren_app/dialogs/progress_dialog.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/no_data.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ConversationsTab extends StatelessWidget {
  const ConversationsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChatController chatController = Get.find();
    /// Initialization
    final i18n = AppLocalizations.of(context);
    final pr = ProgressDialog(context);

    return Column(
      children: [
        /// Conversations stream
        Expanded(
          child: StreamBuilder<List<types.Room>>(
              stream: chatController.streamRoomlist,
              builder: (context, snapshot) {
                /// Check data
                if (!snapshot.hasData) {
                  return const Frankloader();
                } else if (snapshot.data!.isEmpty) {
                  /// No conversation
                  return const NoData(text: "No messages");
                } else {
                  return ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) =>
                    const Divider(height: 10),
                    itemCount: snapshot.data!.length,
                    itemBuilder: ((context, index) {
                      /// Get conversation DocumentSnapshot<Map<String, dynamic>>
                      final types.Room
                          room = snapshot.data![index];

                      return Text(room.id);
                      /// Show conversation
                      // return Container(
                      //   color: !conversation[MESSAGE_READ]
                      //       ? Theme.of(context).primaryColor.withAlpha(40)
                      //       : null,
                      //   child: ListTile(
                      //     leading: CircleAvatar(
                      //       backgroundColor: Theme.of(context).primaryColor,
                      //       backgroundImage: NetworkImage(
                      //         conversation[USER_PROFILE_PHOTO],
                      //       ),
                      //       onBackgroundImageError: (e, s) =>
                      //           {debugPrint(e.toString())},
                      //     ),
                      //     title: Text(conversation[USER_FULLNAME].split(" ")[0],
                      //         style: const TextStyle(fontSize: 18)),
                      //     subtitle: snapshot.data![index].updatedAt),
                      //     trailing: Icon(Iconsax.add),
                      //     onTap: () async {
                      //       Navigator.of(context).push(MaterialPageRoute(
                      //           builder: (context) => BotChatScreen()));
                      //     },
                      //   ),

                    }),
                  );
                }
              }),
        ),
      ],
    );
  }
}
