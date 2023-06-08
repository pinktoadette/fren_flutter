import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/chatroom.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/image/image_rounded.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class BotProfileCard extends StatefulWidget {
  final Bot bot;
  final bool? showStatus;
  final Chatroom? room;
  final int? roomIdx;

  const BotProfileCard(
      {Key? key, required this.bot, this.showStatus, this.room, this.roomIdx})
      : super(key: key);
  @override
  _BotProfileCardState createState() => _BotProfileCardState();
}

class _BotProfileCardState extends State<BotProfileCard> {
  final _botPrompt = TextEditingController(text: "");
  ChatController chatController = Get.find(tag: 'chatroom');
  BotController botController = Get.find(tag: 'bot');
  bool isLoading = false;

  bool disableTextEdit = true;
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
              ? const Frankloader(height: 150, width: 100)
              : const SizedBox(height: 50),
          // if (widget.room?.chatroomId == null) _showPricing(),
        ],
      ),
    );
  }
}
