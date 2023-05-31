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
import 'package:machi_app/widgets/bot/explore_bot.dart';
import 'package:machi_app/widgets/bot/prompt_create.dart';
import 'package:machi_app/widgets/common/frosted_app_bar.dart';
import 'package:machi_app/widgets/common/no_data.dart';

import '../datas/user.dart';

class ConversationsTab extends StatefulWidget {
  const ConversationsTab({Key? key}) : super(key: key);

  @override
  _ConversationsTabState createState() => _ConversationsTabState();
}

class _ConversationsTabState extends State<ConversationsTab> {
  ChatController chatController = Get.find(tag: 'chatroom');
  int pageNum = 1;
  final _chatroomApi = ChatroomMachiApi();
  final _botApi = BotApi();
  User self = UserModel().user;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(handleScrolling);
  }

  void handleScrolling() async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent) {
      setState(() {
        pageNum += 1;
      });
      await _chatroomApi.getAllMyRooms(limit: PAGE_CHAT_LIMIT, page: pageNum);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: RefreshIndicator(
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                FrostedAppBar(
                    title: Text(
                      _i18n.translate("chat"),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    showLeading: true,
                    actions: <Widget>[
                      IconButton(
                          onPressed: () {
                            _createBot(context);
                          },
                          icon: const Icon(Iconsax.message_add_1)),
                      IconButton(
                          onPressed: () {
                            _viewBots(context);
                          },
                          icon: const Icon(Iconsax.messages)),
                      IconButton(
                          onPressed: () async {
                            Bot bot =
                                await _botApi.getBot(botId: DEFAULT_BOT_ID);
                            SetCurrentRoom().setNewBotRoom(bot, true);
                          },
                          icon: const Icon(Iconsax.message_edit))
                    ]),
                SliverList.separated(
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
                          SetCurrentRoom().updateRoomAsCurrentRoom(room, index);
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                            )));
                  }),
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
                )
              ],
            ),
            onRefresh: () {
              setState(() {
                pageNum = 1;
              });
              return _chatroomApi.getAllMyRooms(
                  page: pageNum, clearRooms: true);
            }));
  }

  void _createBot(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => FractionallySizedBox(
            heightFactor: 0.9,
            child: DraggableScrollableSheet(
              snap: true,
              initialChildSize: 1,
              minChildSize: 1,
              builder: (context, scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: const CreateMachiWidget(),
              ),
            )));
  }

  void _viewBots(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      builder: (context) {
        return const FractionallySizedBox(
            heightFactor: 0.9, child: ExploreMachi());
      },
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
