import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/bot_api.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/animations/loader.dart';
import 'package:fren_app/widgets/no_data.dart';
import 'package:iconsax/iconsax.dart';

class ListMyBot extends StatefulWidget {
  const ListMyBot({Key? key}) : super(key: key);

  @override
  _ListMyBotWidget createState() => _ListMyBotWidget();
}

class _ListMyBotWidget extends State<ListMyBot> {
  final _botApi = BotApi();
  List<Bot> _listBot = [];

  Future<void> _fetchAllBots() async {
    List<Bot> result = await _botApi.getAllBots(5, 0);
    setState(() => _listBot = result);
  }

  @override
  void initState() {
    super.initState();
    _fetchAllBots();
  }

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    if (_listBot == null) {
      return Frankloader();
    } else if (_listBot.isEmpty) {
      /// No match
      return NoData(text: _i18n.translate("no_match"));
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: _listBot.length,
            itemBuilder: (context, index) => InkWell(
                  onTap: () {},
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            SizedBox(
                                width: width * 0.35,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: _listBot[index].profilePhoto != ""
                                        ? Image.network(
                                            _listBot[index].profilePhoto!,
                                            fit: BoxFit.cover,
                                          )
                                        : Frankloader()))
                          ])),
                      SizedBox(
                          width: width * 0.6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "${_listBot[index].name} - ${_listBot[index].domain}"),
                                  Text(
                                    _listBot[index].about,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                  // Flexible(
                                  //     fit: FlexFit.tight,
                                  //     child: Text(
                                  //       _listBot[index].about,
                                  //       overflow: TextOverflow.ellipsis,
                                  //     )),
                                ],
                              ),
                            ],
                          )),
                      const Divider()
                    ],
                  ),
                )),
      );
    }
  }

  void _showBotInfo(Bot bot) {
    double height = MediaQuery.of(context).size.height;

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: max(height, 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              BotProfileCard(
                bot: bot,
                showPurchase: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}
