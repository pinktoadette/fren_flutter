import 'dart:ui';

import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/api/machi/chatroom_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/controller/set_room_bot.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/chatroom.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/helpers/truncate_text.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../datas/user.dart';

class ConversationsTab extends StatelessWidget {
  final _chatroomApi = ChatroomMachiApi();
  final _botApi = BotApi();

  ConversationsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChatController chatController = Get.find(tag: 'chatroom');
    User self = UserModel().user;

    /// Initialization
    final _i18n = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 10),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          title: Text(
            _i18n.translate("chat"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: <Widget>[
            IconButton(
                onPressed: () async {
                  Bot bot = await _botApi.getBot(botId: DEFAULT_BOT_ID);
                  SetCurrentRoom().setNewBotRoom(bot, true);
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
                            height: AD_HEIGHT,
                            width: width,
                            color: Theme.of(context).colorScheme.background,
                            child: const InlineAdaptiveAds(),
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
                      if (user.id != self.userId) {
                        allUsers += ", ${user.firstName!}";
                      }
                    }
                    final bool isRead = room.read ?? false;

                    return InkWell(
                      onTap: () async {
                        SetCurrentRoom().updateRoomReadBot(room, index);
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
                                        .headlineSmall),
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
        return Flexible(child: Text(truncateText(100, text)));
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
