import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/bot_model.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/no_data.dart';
import 'package:get/get.dart';

class ManageBotScreen extends StatefulWidget {
  const ManageBotScreen({Key? key}) : super(key: key);

  @override
  _ManageBotState createState() => _ManageBotState();
}

class _ManageBotState extends State<ManageBotScreen> {
  final _botApi = BotModel();
  List<Bot>? _myOwnBot;

  @override
  void initState() {
    super.initState();
    _fetchMyCreateBot();
  }

  Future<void> _fetchMyCreateBot() async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> bots =
        await _botApi.getMyCreatedBot();
    List<Bot> result = [];
    for (var doc in bots) {
      result.add(Bot.fromDocument({...doc.data(), BOT_ID: doc.id}));
    }
    setState(() => _myOwnBot = result);
  }

  @override
  Widget build(BuildContext context) {
    final BotController botController = Get.find();
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
    if (_myOwnBot == null) {
      return const Frankloader();
    } else if (_myOwnBot!.isEmpty) {
      /// No match
      return NoData(text: _i18n.translate("no_match"));
    } else {
      /// Load matches
      return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: _myOwnBot!.length,
          itemBuilder: (context, index) => InkWell(
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(30),
                        child: BotProfileCard(
                            bot: _myOwnBot![index], showStatus: true))
                  ],
                ),
              ));
    }
  }
}
