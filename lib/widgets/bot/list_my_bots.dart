import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/bot_api.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/animations/loader.dart';
import 'package:fren_app/widgets/bot/row_bot_info.dart';
import 'package:fren_app/widgets/no_data.dart';

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
      return Scaffold(
          appBar: AppBar(
            title: Text(
              _i18n.translate("start_chat_with"),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            automaticallyImplyLeading: false,
          ),
          body: ListView.separated(
              separatorBuilder: (context, index) {
                if ((index + 1) % 5 == 0) {
                  return Container(
                    height: 200,
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
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: _listBot.length,
              itemBuilder: (context, index) =>
                  RowMachiInfo(bot: _listBot[index], showChat: true)));
    }
  }
}
