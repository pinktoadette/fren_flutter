import 'package:fren_app/api/machi/chatroom_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/bot/bot_chat.dart';
import 'package:fren_app/screens/first_time/first_time_user.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/avatar_initials.dart';
import 'package:fren_app/widgets/chat/typing_indicator.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class BotProfileCard extends StatefulWidget {
  final Bot bot;
  final bool? showStatus;
  final bool? showPurchase;
  final Chatroom? room;
  final int? roomIdx;

  const BotProfileCard(
      {Key? key,
      required this.bot,
      this.showStatus,
      this.showPurchase,
      this.room,
      this.roomIdx})
      : super(key: key);
  @override
  _BotProfileCardState createState() => _BotProfileCardState();
}

class _BotProfileCardState extends State<BotProfileCard> {
  final _botPrompt = TextEditingController(text: "");
  ChatController chatController = Get.find();
  BotController botController = Get.find();
  final _chatroomApi = ChatroomMachiApi();
  bool isLoading = false;

  bool disableTextEdit = true;
  late AppLocalizations _i18n;
  final TextEditingController personalityController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _botPrompt.dispose();
    personalityController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 180,
            child: ListTile(
                isThreeLine: true,
                leading: AvatarInitials(
                    photoUrl: widget.bot.profilePhoto ?? "",
                    username: widget.bot.name),
                dense: true,
                focusColor: Theme.of(context).secondaryHeaderColor,
                title: Text(
                  "${widget.bot.name} - ${widget.bot.modelType.name}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bot.subdomain,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Flexible(
                                    child: Text(widget.bot.about,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall))
                              ],
                            ),
                          ],
                        ),
                      ],
                    ))),
          ),
          isLoading == true
              ? Frankloader(height: 50, width: 50)
              : const SizedBox(height: 50),
          if (widget.room?.chatroomId == null) _showPricing(),
          if (widget.showPurchase == true)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Iconsax.box),
                    label: Text(_i18n.translate("bot_try")),
                    onPressed: () async {
                      _tryBot();
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Iconsax.element_plus),
                    label: Text(_i18n.translate("add_machi")),
                    onPressed: () {},
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _showPricing() {
    return Row(children: <Widget>[
      Expanded(
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "Price: ${widget.bot.price ?? "Free"}",
                style: Theme.of(context).textTheme.labelMedium,
              ))),
    ]);
  }

  void _tryBot() async {
    setState(() {
      isLoading = true;
    });
    botController.bot = widget.bot;
    await _chatroomApi.tryBot();

    /// it is the last one in roomlist, since we just added immediately after api call
    int index = chatController.roomlist.length;
    Get.to(() => const BotChatScreen(), arguments: {
      "room": chatController.roomlist[index - 1],
      "index": index - 1,
      "isTrial": true
    });
    setState(() {
      isLoading = false;
    });
  }

  /// Add machi. Check if machi is free or not
  /// if free just call api.
  void_addMachi() async {}
}
