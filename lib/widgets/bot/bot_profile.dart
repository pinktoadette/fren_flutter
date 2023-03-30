import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/bot/bot_chat.dart';
import 'package:fren_app/screens/first_time/first_time_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class BotProfileCard extends StatefulWidget {
  final Bot bot;
  final bool? showStatus;
  final bool? showPurchase;
  final Chatroom? room;

  const BotProfileCard(
      {Key? key,
      required this.bot,
      this.showStatus,
      this.showPurchase,
      this.room})
      : super(key: key);
  @override
  _BotProfileCardState createState() => _BotProfileCardState();
}

class _BotProfileCardState extends State<BotProfileCard> {
  List<String> _moodList = [];
  String? _selectedMood;
  bool disableSelect = true;
  final TextEditingController personalityController = TextEditingController();

  Future<void> _loadMood() async {
    String data = await rootBundle.loadString("assets/json/mood.json");
    List<String> mood = List.from(jsonDecode(data) as List<dynamic>);

    setState(() {
      _moodList = mood;
    });

    if (widget.room != null) {
      _selectedMood = widget.room!.personality;

      // only creator of the room can change the mmod
      if (UserModel().user.userId == widget.room!.creatorUser) {
        disableSelect = false;
      }
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
    personalityController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 10;

    return Center(
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              isThreeLine: true,
              leading: const Icon(Iconsax.box_tick),
              title: Text("Name: ${widget.bot.name}"),
              subtitle: Text(
                  "Domain: ${widget.bot.domain} - ${widget.bot.subdomain} \n\n${widget.bot.about}"),
            ),
            Row(children: <Widget>[
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(30),
                child: widget.bot.price != null
                    ? Text(
                        "Price: ${widget.bot.price! <= 0 ? "Free" : widget.bot.price} \n\n${widget.bot.about}")
                    : const Text(""),
              )),
            ]),
            if (widget.showStatus == true)
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(
                            widget.bot.isActive == false
                                ? 'Unpublished'
                                : 'Published',
                            style: TextStyle(
                                color: widget.bot.isActive == false
                                    ? APP_ERROR
                                    : APP_SUCCESS)),
                        const SizedBox(width: 120),
                        widget.bot.isActive == false
                            ? ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Step2Container()),
                                  );
                                },
                                child: const Text('Publish'))
                            : OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Step2Container()),
                                  );
                                },
                                child: const Text('Edit'))
                      ],
                    ),
                  ),
                ],
              ),
            if (widget.showPurchase == true)
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 250,
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            child: const Text("Free to Try"),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const BotChatScreen()));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            if (widget.room?.chatroomId != null)
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 50),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Current mood: "),
                          DropdownButton(
                            items: _moodList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: _selectedMood,
                            onChanged: disableSelect
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedMood = value as String?;
                                    });
                                  },
                            disabledHint: disableSelect
                                ? null
                                : const Text(
                                    "Only creator of chatroom can change."),
                          ),
                          const SizedBox(width: 20),
                        ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(onPressed: () {}, child: const Text('OK')),
                    ],
                  )
                ],
              )
          ],
        ),
      ),
    );
  }

  void _tryBot() {
    // save trial chances - limit to 5 chats
  }
}
