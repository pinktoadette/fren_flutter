import 'package:machi_app/controller/set_room_bot.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/image/image_rounded.dart';
import 'package:iconsax/iconsax.dart';

class RowMachiInfo extends StatelessWidget {
  final Bot bot;
  final bool showChat;
  const RowMachiInfo({Key? key, required this.bot, this.showChat = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double padding = 10;
    double imageWidth = width * 0.2 + 5;
    double textWidth = width - (padding * 2 + imageWidth + 30);
    return Container(
        padding: EdgeInsets.all(padding),
        width: width - padding * 2,
        child: InkWell(
          onTap: () {
            Future(() {
              SetCurrentRoom().setNewBotRoom(bot, true);
            });
            Navigator.pop(context);
          },
          child: Row(
            children: [
              RoundedImage(
                  width: imageWidth,
                  height: imageWidth,
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
                      height: 80,
                      width: textWidth,
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
