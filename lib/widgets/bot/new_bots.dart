import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/bot_model.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:fren_app/widgets/no_data.dart';
import 'package:iconsax/iconsax.dart';

class ListNewBotWidget extends StatefulWidget {
  const ListNewBotWidget({Key? key}) : super(key: key);

  @override
  _ListNewBotWidget createState() => _ListNewBotWidget();
}

class _ListNewBotWidget extends State<ListNewBotWidget> {
  final _botApi = BotModel();
  List<Bot>? _listBot;

  Future<void> _fetchAllBots() async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> bots =
        await _botApi.getAllBotsTrend();
    List<Bot> result = [];
    for (var doc in bots) {
      result.add(Bot.fromDocument({...doc.data(), BOT_ID: doc.id}));
    }
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
    } else if (_listBot!.isEmpty) {
      /// No match
      return NoData(text: _i18n.translate("no_match"));
    } else {
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          height: 80.0,
          child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: _listBot!.length,
              itemBuilder: (context, index) => InkWell(
                    child: Column(
                      children: [
                        Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28)),
                            child: SizedBox(
                              width: 200,
                              height: 70,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      onTap: () {
                                        _showBotInfo(_listBot![index]);
                                      },
                                      // contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      minLeadingWidth: 15,
                                      leading: _listBot![index].profilePhoto !=
                                              ""
                                          ? CircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              backgroundImage: NetworkImage(
                                                _listBot![index].profilePhoto ??
                                                    "",
                                              ))
                                          : const Icon(Iconsax.box_tick),
                                      dense: true,
                                      focusColor: Theme.of(context)
                                          .secondaryHeaderColor,
                                      title: Text(
                                          "${_listBot![index].name} - ${_listBot![index].domain}"),
                                      subtitle: Text(_listBot![index]
                                          .subdomain
                                          .substring(
                                              0,
                                              _listBot![index]
                                                          .subdomain
                                                          .length >
                                                      10
                                                  ? 10
                                                  : _listBot![index]
                                                      .subdomain
                                                      .length)),
                                    ),
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
