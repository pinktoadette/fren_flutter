import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/set_room_bot.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/image/image_rounded.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class RowMachiInfo extends StatelessWidget {
  final Bot bot;
  bool? showChat = false;
  RowMachiInfo({Key? key, required this.bot, this.showChat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BotController botController = Get.find(tag: 'bot');
    final _i18n = AppLocalizations.of(context);

    final width = MediaQuery.of(context).size.width;
    double widthPercent = 0.2;

    // Note: timeline widget row is saw under 'machi' case
    return Container(
        padding: const EdgeInsets.all(10),
        width: width,
        child: InkWell(
          onTap: () {
            SetCurrentRoom().setNewBotRoom(bot, true);
            // _showBotInfo(context);
          },
          child: Row(
            children: [
              RoundedImage(
                  width: (width * widthPercent) + 5,
                  height: (width * widthPercent) + 5,
                  icon: const Icon(Iconsax.box_add),
                  photoUrl: bot.profilePhoto ?? ""),
              const SizedBox(width: 5),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bot.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                      height: width * widthPercent,
                      width: width * (1 - widthPercent) - 30,
                      child: Text(
                        bot.about,
                        style: Theme.of(context).textTheme.bodySmall,
                      ))
                ],
              )
            ],
          ),
        ));
  }
}
