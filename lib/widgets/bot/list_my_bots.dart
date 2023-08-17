import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/set_room_bot.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/bot/bot_profile.dart';
import 'package:machi_app/widgets/common/no_data.dart';

class ListMyBot extends StatefulWidget {
  const ListMyBot({Key? key}) : super(key: key);

  @override
  State<ListMyBot> createState() => _ListMyBotWidget();
}

class _ListMyBotWidget extends State<ListMyBot> {
  final _botApi = BotApi();
  List<Bot> _listBot = [];

  Future<void> _fetchAllBots() async {
    if (!mounted) {
      return;
    }
    List<Bot> result = await _botApi.myAddedMachi();
    setState(() => _listBot = result);
  }

  @override
  void initState() {
    _fetchAllBots();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    if (_listBot.isEmpty) {
      /// No match
      return NoData(text: i18n.translate("no_match"));
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              i18n.translate("start_chat_with"),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            automaticallyImplyLeading: false,
          ),
          body: ListView.separated(
              separatorBuilder: (context, index) {
                if ((index + 1) % 3 == 0) {
                  return Container(
                    height: 200,
                    color: Theme.of(context).colorScheme.background,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Container(
                        height: AD_HEIGHT,
                        width: width,
                        color: Theme.of(context).colorScheme.background,
                        child: const InlineAdaptiveAds(),
                      ),
                    ),
                  );
                } else {
                  return const Divider();
                }
              },
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: _listBot.length,
              itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    Future(() {
                      SetCurrentRoom()
                          .setNewBotRoom(bot: _listBot[index], createNew: true);
                    });
                    Navigator.pop(context);
                  },
                  child: BotProfileCard(bot: _listBot[index]))));
    }
  }
}
