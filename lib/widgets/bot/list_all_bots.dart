import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/bot_api.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:fren_app/widgets/no_data.dart';
import 'package:iconsax/iconsax.dart';

class ListAllBots extends StatefulWidget {
  const ListAllBots({Key? key}) : super(key: key);

  @override
  _ListAllBotWidget createState() => _ListAllBotWidget();
}

class _ListAllBotWidget extends State<ListAllBots> {
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

    if (_listBot == null) {
      return const Frankloader();
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
                    child: Column(
                      children: [
                        Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28)),
                            child: SizedBox(
                              height: 150,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                        onTap: () {
                                          _showBotInfo(_listBot[index]);
                                        },
                                        // contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        minLeadingWidth: 15,
                                        leading:
                                            _listBot[index].profilePhoto != ""
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      _listBot[index]
                                                              .profilePhoto ??
                                                          "",
                                                    ))
                                                : const Icon(Iconsax.box_tick),
                                        dense: true,
                                        focusColor: Theme.of(context)
                                            .secondaryHeaderColor,
                                        title: Text(
                                            "${_listBot[index].name} - ${_listBot[index].domain}"),
                                        subtitle: Align(
                                            alignment: Alignment.topLeft,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    _listBot[index].subdomain),
                                                Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                            child: Text(_listBot[
                                                                            index]
                                                                        .about
                                                                        .length >
                                                                    80
                                                                ? _listBot[index]
                                                                        .about
                                                                        .substring(
                                                                            0,
                                                                            80) +
                                                                    '...'
                                                                : _listBot[
                                                                        index]
                                                                    .about))
                                                      ],
                                                    ),
                                                    const Row(
                                                      children: [
                                                        SizedBox(height: 50),
                                                        Text("Downloads"),
                                                        Spacer(),
                                                        Text("Contributors")
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ))),
                                  ]),
                            ))
                      ],
                    ),
                  )));
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
