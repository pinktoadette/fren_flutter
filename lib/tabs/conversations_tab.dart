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
              chatController.onLoadCurrentRoom(chatController.emptyRoom);
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
          child: chatController.roomlist.isEmpty
              ? Align(
                  alignment: Alignment.center,
                  child: Text(
                    _i18n.translate("no_conversation"),
                    textAlign: TextAlign.center,
                  ),
                )
              : Obx(() => ListView.separated(
                  reverse: true,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 10),
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
                    final bool isRead = room.read ?? false;

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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    room.bot.domain,
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  )
                                ]),
                            Row(
                              children: [
                                Text(allUsers,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const Spacer(),
                                Text(formatDate(lastMsg[CREATED_AT]),
                                    textAlign: TextAlign.right,
                                    style:
                                        Theme.of(context).textTheme.labelSmall),
                                !isRead
                                    ? const Icon(
                                        Iconsax.stop_circle,
                                        size: 12,
                                      )
                                    : const SizedBox(
                                        width: 15,
                                        height: 15,
                                      )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                lastMsg.containsKey("type")
                                    ? _formatMessages(context, lastMsg["type"],
                                        lastMsg["text"])
                                    : const Text(""),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  })))),
    );
  }

  Widget _formatMessages(BuildContext context, String type, String text) {
    final _i18n = AppLocalizations.of(context);
    switch (type) {
      case 'text':
        return Flexible(
            child:
                Text(text.length > 100 ? "${text.substring(0, 90)}..." : text));
      case 'image':
      case 'video':
        return SizedBox(
          child: Row(children: [
            const Icon(Iconsax.attach_circle),
            Text(_i18n.translate("media_attached"))
          ]),
        );
      default:
        return const Text("");
    }
  }
}
