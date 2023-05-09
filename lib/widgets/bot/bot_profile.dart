import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/api/machi/chatroom_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/controller/set_room_bot.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/chatroom.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/image/image_rounded.dart';
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
  ChatController chatController = Get.find(tag: 'chatroom');
  BotController botController = Get.find(tag: 'bot');
  final _chatroomApi = ChatroomMachiApi();
  final _botApi = BotApi();
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
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 200,
            child: ListTile(
                isThreeLine: true,
                leading: RoundedImage(
                    width: width * 0.15,
                    height: width * 0.15,
                    icon: const Icon(Iconsax.box_add),
                    photoUrl: widget.bot.profilePhoto ?? ""),
                dense: true,
                focusColor: Theme.of(context).secondaryHeaderColor,
                title: Text(
                  widget.bot.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                subtitle: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.bot.modelType.name),
                        Text(
                          widget.bot.subdomain,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(widget.bot.about,
                            style: Theme.of(context).textTheme.bodySmall)
                      ],
                    ))),
          ),
          isLoading == true
              ? Frankloader(height: 50, width: 50)
              : const SizedBox(height: 50),
          // if (widget.room?.chatroomId == null) _showPricing(),
          if (widget.showPurchase == true)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _displayButtons(),
              ),
            )
        ],
      ),
    );
  }

  List<Widget> _displayButtons() {
    if (widget.bot.isSubscribed == true) {
      return [const Text("You have this machi")];
    } else {
      return [
        ElevatedButton.icon(
          icon: const Icon(Iconsax.message),
          label: Text(_i18n.translate("chat")),
          onPressed: () async {
            _tryBot();
          },
        ),
        // ElevatedButton.icon(
        //   icon: const Icon(Iconsax.element_plus),
        //   label: Text(_i18n.translate("add_machi")),
        //   onPressed: () {
        //     _addMachi();
        //   },
        // ),
      ];
    }
  }

  void _tryBot() async {
    setState(() {
      isLoading = true;
    });
    Navigator.of(context).pop();
    SetCurrentRoom().setNewBotRoom(widget.bot, true);

    setState(() {
      isLoading = false;
    });
  }
}
