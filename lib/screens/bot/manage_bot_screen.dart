import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/dialogs/progress_dialog.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/bot_model.dart';
import 'package:fren_app/screens/bot/add_bot_step1.dart';
import 'package:fren_app/screens/bot/add_bot_step2.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/no_data.dart';
import 'package:fren_app/widgets/processing.dart';
import 'package:fren_app/widgets/users_grid.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ManageBot extends StatefulWidget {
  const ManageBot({Key? key}) : super(key: key);

  @override
  _ManageBotState createState() => _ManageBotState();
}

class _ManageBotState extends State<ManageBot> {
  late AppLocalizations _i18n;
  late ProgressDialog _pr;
  final _botApi = BotModel();
  List<Bot>? _myOwnBot;

  @override
  void initState() {
    super.initState();
    _fetchMyCreateBot();
  }

  Future<void> _fetchMyCreateBot() async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> bots = await _botApi.getMyCreatedBot();
    List<Bot> result = [];
    bots.forEach((doc) {
      result.add(Bot.fromDocument({...doc.data()!, BOT_ID: doc.id}));
    });
    setState(() => _myOwnBot = result);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () {
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
    final BotController botController = Get.find();

    final _i18n = AppLocalizations.of(context);
    /// Check result
    if (_myOwnBot == null) {
      return const Frankloader();
    } else if (_myOwnBot!.isEmpty) {
      /// No match
      return NoData( text: _i18n.translate("no_match"));
    } else {
      /// Load matches
      return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: _myOwnBot!.length,
        itemBuilder: (context, index) => InkWell(
          onTap: (){
              botController.bot = _myOwnBot![index];
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Step2Container()),
              );
            },
          child:      Column(
            children: [
              Padding(
                  padding:  const EdgeInsets.all(30),
                  child:BotProfileCard(bot: _myOwnBot![index], showStatus: true)
              )
            ],
          ),
        )
      );
    }
  }
}



