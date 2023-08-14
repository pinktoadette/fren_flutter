import 'package:cached_network_image/cached_network_image.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/chatroom.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
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
  State<BotProfileCard> createState() => _BotProfileCardState();
}

class _BotProfileCardState extends State<BotProfileCard> {
  bool disableTextEdit = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    TextStyle header = const TextStyle(
        color: APP_INVERSE_PRIMARY_COLOR,
        fontSize: 20,
        fontWeight: FontWeight.bold);
    TextStyle body =
        const TextStyle(color: APP_INVERSE_PRIMARY_COLOR, fontSize: 16);

    return Card(
      margin: const EdgeInsets.all(20),
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 250,
            width: width,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Positioned.fill(
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    memCacheWidth: width.toInt(),
                    imageUrl: widget.bot.profilePhoto ?? "",
                    progressIndicatorBuilder: (context, url, progress) =>
                        loadingButton(size: 20),
                    errorWidget: (context, url, error) =>
                        const Icon(Iconsax.gallery_slash),
                  ),
                ),
                Container(
                  color: Colors.black.withOpacity(0.5),
                  width: width,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.bot.name, style: header),
                      Text(widget.bot.modelType.name, style: body),
                      const Spacer(),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: Text(
                          widget.bot.about,
                          style: body,
                          overflow: TextOverflow.fade,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
