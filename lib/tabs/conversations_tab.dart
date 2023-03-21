import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/api/machi/chatroom_api.dart';
import 'package:fren_app/controller/chat_controller.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:fren_app/dialogs/progress_dialog.dart';
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
    final i18n = AppLocalizations.of(context);
    final pr = ProgressDialog(context);
    final width = MediaQuery.of(context).size.width;

    return RefreshIndicator(
        onRefresh: () {
          // Refresh Functionality
          return _chatroomApi.getAllMyRooms();
        },
        child: StreamBuilder<List<Chatroom>>(
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
                          final Chatroom
                          room = snapshot.data![index];
                          final lastMsg = room.messages.isNotEmpty ? room.messages[0].toJson() : { 'text': 'Empty message', 'createdAt': DateTime.now().millisecondsSinceEpoch };
                          String allUsers = '';
                          for (var user in room.users) {
                            allUsers += "${user.firstName!} ";
                          }

                          return GestureDetector(
                            onTap: () {
                              chatController.currentRoom = room;
                              chatController.onLoadRoomMessages();

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BotChatScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                          width: width *0.75-20,
                                          child:  Text(allUsers)
                                      ),
                                      SizedBox(
                                        width: width*0.25-20,
                                        child: Text(lastMsg['createdAt'].toString(), style: Theme.of(context).textTheme.labelSmall),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      (room.messages.isNotEmpty) & (lastMsg["text"] != null) ?
                                      Flexible(
                                        child: Text( lastMsg["text"].length > 100 ? lastMsg["text"].substring(0, 90) : lastMsg["text"])
                                      ) : const Text("")
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                    );
                  }
                }
            )

    );
    return Column(
      children: [
        /// Conversations stream
        Expanded(
          child: StreamBuilder<List<Chatroom>>(
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
                        final Chatroom
                        room = snapshot.data![index];

                        return GestureDetector(
                          onTap: () {
                            chatController.currentRoom = room;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BotChatScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Column(
                              children: [
                                Text(room.chatroomId),
                                const SizedBox(
                                  height: 50,
                                ),
                                Text(room.createdAt.toString())
                              ],
                            ),
                          ),
                        );
                      })
                  );
                }
              }
          )
        ),
      ],
    );
  }
}
