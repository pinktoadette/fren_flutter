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
import 'package:lottie/lottie.dart';

class ListAllBotsVertically extends StatefulWidget {
  const ListAllBotsVertically({Key? key}) : super(key: key);

  @override
  _ListAllBotWidget createState() => _ListAllBotWidget();
}

class _ListAllBotWidget extends State<ListAllBotsVertically> {
  final _botApi = BotModel();
  List<Bot>? _listBot;

  Future<void> _fetchAllBots() async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> bots = await _botApi.getAllBotsTrend();
    List<Bot> result = [];
    for (var doc in bots) {
      result.add(Bot.fromDocument({...doc.data()!, BOT_ID: doc.id}));
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
      return NoData( text: _i18n.translate("no_match"));
    } else {
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: _listBot!.length,
                itemBuilder: (context, index) => InkWell(
                  child: Column(
                    children: [
                      Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                          child: SizedBox(
                            height: 100,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    onTap: () {
                                      _showBotInfo(_listBot![index]);
                                    },
                                    // contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    minLeadingWidth: 15,
                                    leading: _listBot![index]?.profilePhoto != "" ? CircleAvatar(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      backgroundImage: NetworkImage(
                                        _listBot![index]?.profilePhoto ?? "",
                                      )) : const Icon(Iconsax.box_tick),
                                    dense: true,
                                    focusColor: Theme.of(context).secondaryHeaderColor,
                                    title: Text("${_listBot![index].name} - ${_listBot![index].domain}"),
                                    subtitle: Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              TextButton(
                                                child: Text(_i18n.translate("CANCEL")),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                onPressed: () {  },
                                                child: const Text("Contribute"),
                                              ),
                                            ],
                                          ),
                                        )


                                        // Column(
                                        //   crossAxisAlignment: CrossAxisAlignment.start,
                                        //   children: [
                                        //     Text(_listBot![index].subdomain),
                                        //     Column(
                                        //       children:[
                                        //       Row(
                                        //        children: const [
                                        //            SizedBox(height: 50),
                                        //            Text("Downloads"),
                                        //            Spacer(),
                                        //            Text("Contributors")
                                        //        ],
                                        //       )
                                        //       ],
                                        //     ),
                                        //   ],
                                        // )
                                    )
                                ),
                            ]),
                          )
                      )
                    ],
                  ),
                )
      ));
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
              BotProfileCard(bot: bot, showPurchase: true,)
            ],
          ),
        ),
      ),
    );
  }
}