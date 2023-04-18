import 'package:fren_app/api/machi/bot_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/animations/loader.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/no_data.dart';
import 'package:get/get.dart';

class ManageBotScreen extends StatefulWidget {
  const ManageBotScreen({Key? key}) : super(key: key);

  @override
  _ManageBotState createState() => _ManageBotState();
}

class _ManageBotState extends State<ManageBotScreen> {
  final _botApi = BotApi();
  List<Bot> _listBot = [];

  @override
  void initState() {
    super.initState();
    _fetchMyCreateBot();
  }

  Future<void> _fetchMyCreateBot() async {
    List<Bot> result = await _botApi.getAllBots(5, 0);
    setState(() => _listBot = result);
  }

  @override
  Widget build(BuildContext context) {
    final BotController botController = Get.find(tag: 'bot');
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            botController.fetchCurrentBot(DEFAULT_BOT_ID);
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _showMyCreate()),
        ],
      ),
    );
  }

  Widget _showMyCreate() {
    final _i18n = AppLocalizations.of(context);

    /// Check result
    if (_listBot.isEmpty) {
      return Frankloader();
    } else if (_listBot.isEmpty) {
      /// No match
      return NoData(text: _i18n.translate("no_match"));
    } else {
      /// Load matches
      return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: _listBot.length,
          itemBuilder: (context, index) => InkWell(
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(30),
                        child: BotProfileCard(
                            bot: _listBot[index], showStatus: true))
                  ],
                ),
              ));
    }
  }
}
