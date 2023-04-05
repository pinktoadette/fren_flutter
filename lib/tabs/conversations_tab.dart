import 'package:fren_app/api/machi/chatroom_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/helpers/date_format.dart';
import 'package:fren_app/screens/bot/bot_chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ConversationsTab extends StatelessWidget {
  final _chatroomApi = ChatroomMachiApi();

  ConversationsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChatController chatController = Get.find();

    /// Initialization
    final _i18n = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(actions: <Widget>[
        IconButton(
            onPressed: () {
              chatController.addEmptyRoomToList();
              Get.to(() => const BotChatScreen(), arguments: {
                "room": chatController.emptyRoom,
                "index": chatController.roomlist.length - 1
              });
            },
            icon: const Icon(Iconsax.message_edit))
      ]),
      body: RefreshIndicator(
          onRefresh: () {
            // Refresh Functionality
            return _chatroomApi.getAllMyRooms();
          },
          child: Obx(() => ListView.separated(
              reverse: true,
              shrinkWrap: true,
              separatorBuilder: (context, index) => const Divider(height: 10),
              itemCount: chatController.roomlist.length,
              itemBuilder: ((context, index) {
                final Chatroom room = chatController.roomlist[index];
                final lastMsg = room.messages.isNotEmpty
                    ? room.messages[0].toJson()
                    : {
                        'text': 'This is an error. Something went wrong',
                        'createdAt': DateTime.now().millisecondsSinceEpoch
                      };
                String allUsers = "${room.bot.name} ";
                for (var user in room.users) {
                  allUsers += "& ${user.firstName!} ";
                }

                return InkWell(
                  onTap: () {
                    chatController.onLoadCurrentRoom(room);
                    Get.to(() => (const BotChatScreen()),
                        arguments: {"room": room, 'index': index});
                  },
                  child: Container(
                    width: width,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                room.bot.domain,
                                style: Theme.of(context).textTheme.labelSmall,
                              )
                            ]),
                        Row(
                          children: [
                            Text(allUsers,
                                style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            Text(formatDate(lastMsg[CREATED_AT]),
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.labelSmall)
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            lastMsg["type"] == "text"
                                ? Flexible(
                                    child: Text(lastMsg["text"].length > 100
                                        ? "${lastMsg["text"].substring(0, 90)}..."
                                        : lastMsg["text"]))
                                : SizedBox(
                                    child: Row(children: [
                                      const Icon(Iconsax.attach_circle),
                                      Text(_i18n.translate("media_attached"))
                                    ]),
                                  )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              })))),
    );
  }
}
