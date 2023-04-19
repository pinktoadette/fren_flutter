import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/bot_api.dart';
import 'package:fren_app/api/machi/timeline.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/avatar_initials.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/no_data.dart';
import 'package:fren_app/widgets/timeline/timeline_header.dart';
import 'package:iconsax/iconsax.dart';

class Timeline extends StatefulWidget {
  const Timeline({Key? key}) : super(key: key);

  @override
  _TimelineWidget createState() => _TimelineWidget();
}

class _TimelineWidget extends State<Timeline> {
  final _botApi = BotApi();
  final _timelineApi = TimelineApi();

  /// timeline items
  int _offset = 0;
  List _timelines = [];

  Future<void> _getTimeline() async {
    int limit = 30;
    List timeline = await _timelineApi.getTimeline(limit, _offset);
    setState(() {
      _timelines = timeline;
      _offset = _offset + 1;
    });
  }

  @override
  void initState() {
    _getTimeline();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);
    double itemHeight = 200;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (_timelines.isEmpty) {
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
              itemCount: _timelines.length,
              itemBuilder: (context, index) => ListTile(
                    isThreeLine: true,
                    leading: AvatarInitials(
                        radius: 30,
                        photoUrl: _timelines[index]["createdBy"]["photoUrl"],
                        username: _timelines[index]["createdBy"]["username"]),
                    title: TimelineHeader(
                        photoUrl: _timelines[index]["createdBy"]["photoUrl"],
                        username: _timelines[index]["createdBy"]["username"],
                        userId: _timelines[index]["createdBy"]["userId"]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _timelines[index]["text"],
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.left,
                        ),
                        _showTitle(_timelines[index]),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Iconsax.heart),
                          ],
                        )
                      ],
                    ),
                  )));
    }
  }

  Widget _showTitle(dynamic post) {
    double width = MediaQuery.of(context).size.width;
    Widget author = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 10),
        Text(post["createdBy"]["username"]),
      ],
    );
    switch (post["postType"]) {
      case "board":
        if (post["subText"].isNotEmpty) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: width,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          for (var i = 0; i < post["subText"].length; i++)
                            SizedBox(
                                width: 100.0,
                                height: 100.0,
                                child: Card(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: post["subText"][i]["messages"]
                                                ["type"] ==
                                            "image"
                                        ? Image.network(
                                            post["subText"][i]["messages"]
                                                ["image"]["uri"],
                                            fit: BoxFit.cover,
                                          )
                                        : Text(
                                            post["subText"][i]["messages"]
                                                ["text"],
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ))),
                        ]))),
              ]);
        }
        return const SizedBox.shrink();
      case "machi":
      default:
        return const SizedBox.shrink();
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
