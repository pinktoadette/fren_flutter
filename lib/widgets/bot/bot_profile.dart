import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/screens/bot/bot_chat.dart';
import 'package:fren_app/screens/first_time/first_time_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class BotProfileCard extends StatelessWidget {
  final Bot bot;
  final bool? showStatus;
  final bool? showPurchase;
  const BotProfileCard(
      {Key? key, required this.bot, this.showStatus, this.showPurchase})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);
    return Center(
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Iconsax.box_tick),
                title: Text("Name: ${bot.name}"),
                subtitle: Text("Domain: ${bot.domain} - ${bot.subdomain}"),
              ),
              Row(children: <Widget>[
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                      "Price: ${bot.price! <= 0 ? "Free" : bot.price} \n\n${bot.about}"),
                )),
              ]),
              if (showStatus == true)
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Text(
                              bot.isActive == false
                                  ? 'Unpublished'
                                  : 'Published',
                              style: TextStyle(
                                  color: bot.isActive == false
                                      ? APP_ERROR
                                      : APP_SUCCESS)),
                          const SizedBox(width: 120),
                          bot.isActive == false
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
              if (showPurchase == true)
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
                                final BotController botController = Get.find();
                                botController.bot = bot;
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const BotChatScreen()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  void _tryBot() {
    // save trial chances - limit to 5 chats
  }
}
