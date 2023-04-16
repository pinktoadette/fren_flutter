import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/bot_api.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/ads/inline_ads.dart';
import 'package:fren_app/widgets/avatar_initials.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/no_data.dart';

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
    if (!mounted) return;
    setState(() => _listBot = result);
  }

  @override
  void initState() {
    _fetchAllBots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);
    double itemHeight = 200;
    final width = MediaQuery.of(context).size.width;

    if (_listBot.isEmpty) {
      /// No match
      return NoData(text: _i18n.translate("no_match"));
    } else {
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              separatorBuilder: (context, index) {
                if ((index + 1) % 5 == 0) {
                  return Container(
                    height: itemHeight,
                    color: Theme.of(context).colorScheme.background,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Container(
                        height: 150,
                        width: width,
                        color: Colors.yellow,
                        child: const Text('ad placeholder'),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
              itemCount: _listBot.length,
              itemBuilder: (context, index) => InkWell(
                    child: Column(
                      children: [
                        Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28)),
                            child: SizedBox(
                              height: itemHeight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(
                                  children: [
                                    ListTile(
                                        isThreeLine: true,
                                        onTap: () {
                                          _showBotInfo(_listBot[index]);
                                        },
                                        // contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        minLeadingWidth: 15,
                                        leading: AvatarInitials(
                                            photoUrl:
                                                _listBot[index].profilePhoto ??
                                                    "",
                                            username: _listBot[index].name),
                                        dense: true,
                                        focusColor: Theme.of(context)
                                            .secondaryHeaderColor,
                                        title: Text(
                                            "${_listBot[index].name} - ${_listBot[index].modelType.name}"),
                                        subtitle: Align(
                                            alignment: Alignment.topLeft,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(_listBot[index].subdomain),
                                                Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                            child: Text(_listBot[
                                                                            index]
                                                                        .about
                                                                        .length >
                                                                    100
                                                                ? _listBot[index]
                                                                        .about
                                                                        .substring(
                                                                            0,
                                                                            100) +
                                                                    '...'
                                                                : _listBot[
                                                                        index]
                                                                    .about))
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ))),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20, bottom: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            _i18n.translate("bot_owner"),
                                            textAlign: TextAlign.left,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          AvatarInitials(
                                              radius: 10,
                                              userId: _listBot[index]
                                                  .createdBy!
                                                  .userId,
                                              photoUrl: _listBot[index]
                                                  .createdBy!
                                                  .photoUrl,
                                              username: _listBot[index]
                                                  .createdBy!
                                                  .username)
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
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
