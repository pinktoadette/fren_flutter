import 'package:fren_app/api/machi/chatroom_api.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/screens/bot/bot_chat.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/no_data.dart';
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

    return RefreshIndicator(
        onRefresh: () {
          // Refresh Functionality
          return _chatroomApi.getAllMyRooms();
        },
        child: Obx(() => ListView.separated(
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
              String allUsers = '';
              for (var user in room.users) {
                allUsers += "${user.firstName!} ";
              }
              return InkWell(
                onTap: () {
                  Get.to(() => (const BotChatScreen()),
                          arguments: {"room": room, 'index': index})
                      ?.then((_) => {chatController.onLoadCurrentRoom(room)});
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
                          SizedBox(
                              width: width * 0.75 - 20,
                              child: Text(allUsers,
                                  style:
                                      Theme.of(context).textTheme.titleMedium)),
                          SizedBox(
                            width: width * 0.25 - 20,
                            child: Text(lastMsg['createdAt'].toString(),
                                style: Theme.of(context).textTheme.labelSmall),
                          )
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
                                      ? lastMsg["text"].substring(0, 90)
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
            })))
        // child: StreamBuilder<List<Chatroom>>(
        //     stream: chatController.streamRoomlist,
        //     builder: (context, snapshot) {
        //       /// Check data
        //       if (!snapshot.hasData) {
        //         return const Frankloader();
        //       } else if (snapshot.data!.isEmpty) {
        //         /// No conversation
        //         return const NoData(text: "No messages");
        //       } else {
        //         }
        //     })
        );
  }
}
