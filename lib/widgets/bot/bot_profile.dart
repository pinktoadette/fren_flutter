import 'package:fren_app/api/machi/chatroom_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/bot/bot_chat.dart';
import 'package:fren_app/screens/first_time/first_time_user.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/avatar_initials.dart';
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
  final _chatroomApi = ChatroomMachiApi();

  String _prompt = "";
  bool disableTextEdit = true;
  late AppLocalizations _i18n;
  final TextEditingController personalityController = TextEditingController();

  Future<void> _loadMood() async {
    if (widget.room != null) {
      // only creator of the room can change the mmod
      if (UserModel().user.userId == widget.room!.creatorUser) {
        disableTextEdit = false;
      }
      setState(() {
        _prompt = widget.bot.prompt;
      });
    }
  }

  @override
  void initState() {
    _loadMood();
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
    double width = MediaQuery.of(context).size.width - 10;
    double height = MediaQuery.of(context).size.height * 0.4;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
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
          if (widget.room?.chatroomId == null)
            Row(children: <Widget>[
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(10),
                child: widget.bot.price != null
                    ? Text(
                        "Price: ${widget.bot.price! <= 0 ? "Free" : widget.bot.price} \n\n${widget.bot.about}")
                    : const Text(""),
              )),
            ]),
          if (widget.showPurchase == true)
            const SizedBox(
              height: 20,
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  child: const Text("Free to Try"),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const BotChatScreen()));
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Iconsax.add_circle),
                  label: const Text("Machi"),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const BotChatScreen()));
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _tryBot() {
    // save trial chances - limit to 5 chats
  }
}
