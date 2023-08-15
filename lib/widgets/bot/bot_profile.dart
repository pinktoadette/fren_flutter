import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/set_room_bot.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/navigation_helper.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:iconsax/iconsax.dart';

class BotProfileCard extends StatefulWidget {
  final Bot bot;
  final bool? showChatbuttom;

  const BotProfileCard(
      {Key? key, required this.bot, this.showChatbuttom = false})
      : super(key: key);
  @override
  State<BotProfileCard> createState() => _BotProfileCardState();
}

class _BotProfileCardState extends State<BotProfileCard> {
  bool disableTextEdit = true;
  UserController userController = Get.find(tag: 'user');
  late AppLocalizations _i18n;

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
    _i18n = AppLocalizations.of(context);

    TextStyle header = const TextStyle(
        color: APP_INVERSE_PRIMARY_COLOR,
        fontSize: 20,
        fontWeight: FontWeight.bold);
    TextStyle body =
        const TextStyle(color: APP_INVERSE_PRIMARY_COLOR, fontSize: 16);

    return Column(children: [
      Card(
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
      ),
      if (widget.showChatbuttom == true)
        TextButton(
            onPressed: () {
              Get.back();
              NavigationHelper.handleGoToPageOrLogin(
                context: context,
                userController: userController,
                navigateAction: () {
                  SetCurrentRoom().setNewBotRoom(widget.bot, true);
                },
              );
            },
            child: Text(_i18n.translate("lets_chat")))
    ]);
  }
}
