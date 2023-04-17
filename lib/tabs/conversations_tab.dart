import 'package:fren_app/api/machi/chatroom_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/helpers/date_format.dart';
import 'package:fren_app/helpers/date_now.dart';
import 'package:fren_app/screens/bot/bot_chat.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/ads/inline_ads.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ConversationsTab extends StatelessWidget {
  final _chatroomApi = ChatroomMachiApi();

  ConversationsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChatController chatController = Get.find(tag: 'chatroom');

    /// Initialization
    final _i18n = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          title: Text(
            _i18n.translate("chat"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Iconsax.note),
              onPressed: () {},
            ),
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
                  cacheExtent: 1000,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    if ((index + 1) % 5 == 0) {
                      return Container(
                        height: 150,
                        color: Theme.of(context).colorScheme.background,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                              top: 10, bottom: 10),
                          child: Container(
                            height: 150,
                            width: width,
                            color: Colors.yellow,
                            child: const Text('ad placeholder'),
                          ),
                        ),
                      );
                    } else {
                      return const Divider(height: 10);
                    }
                  },
                  itemCount: chatController.roomlist.length,
                  itemBuilder: ((context, index) {
                    final Chatroom room = chatController.roomlist[index];
                    final lastMsg = room.messages.isNotEmpty
                        ? room.messages[0].toJson()
                        : {
                            'text': 'This is an error. Something went wrong',
                            'createdAt': getDateTimeEpoch()
                          };
                    String allUsers = room.bot.name;
                    for (var user in room.users) {
                      allUsers += ", ${user.firstName!}";
                    }
                    final bool isRead = room.read ?? false;

                    return InkWell(
                      onTap: () async {
                        Chatroom updateRoom = room.copyWith(read: true);
                        chatController.updateRoom(index, updateRoom);
                        await _chatroomApi.markAsRead(room.chatroomId);
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
                              children: [
                                Text(allUsers,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const Spacer(),
                                Text(formatDate(lastMsg[CREATED_AT]),
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _formatMessages(context, lastMsg),
                                !isRead
                                    ? const Icon(Iconsax.info_circle1,
                                        size: 14, color: APP_ACCENT_COLOR)
                                    : const SizedBox(
                                        width: 5,
                                        height: 5,
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

  Widget _formatMessages(BuildContext context, Map<String, dynamic> message) {
    final _i18n = AppLocalizations.of(context);
    switch (message["type"]) {
      case 'text':
        String text = message['text'];
        return Flexible(
            child:
                Text(text.length > 100 ? "${text.substring(0, 90)}..." : text));
      case 'image':
        return SizedBox(
          child: Row(children: [
            const Icon(Iconsax.paperclip, size: 14),
            Text(_i18n.translate("media_attached"),
                style: const TextStyle(fontStyle: FontStyle.italic))
          ]),
        );
      case 'video':
        return SizedBox(
          child: Row(children: [
            const Icon(Iconsax.paperclip, size: 14),
            Text(_i18n.translate("media_attached"),
                style: const TextStyle(fontStyle: FontStyle.italic))
          ]),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
