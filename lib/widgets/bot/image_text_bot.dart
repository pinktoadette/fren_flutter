import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/no_data.dart';

import 'row_bot_info.dart';

class ImageTextBots extends StatefulWidget {
  const ImageTextBots({Key? key}) : super(key: key);

  @override
  _ImageTextBotsState createState() => _ImageTextBotsState();
}

class _ImageTextBotsState extends State<ImageTextBots> {
  final _botApi = BotApi();
  List<Bot> _listBot = [];

  Future<void> _fetchAllBots() async {
    List<Bot> result = await _botApi.getAllBots(30, 0, BotModelType.imageText);
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
      return NoData(text: _i18n.translate("no_result"));
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
                  return const Divider();
                }
              },
              itemCount: _listBot.length,
              itemBuilder: (context, index) =>
                  RowMachiInfo(bot: _listBot[index])));
    }
  }
}
