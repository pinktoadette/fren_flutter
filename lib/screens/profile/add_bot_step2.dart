import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/dialogs/progress_dialog.dart';
import 'package:fren_app/helpers/app_helper.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/app_model.dart';
import 'package:fren_app/models/bot_model.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/profile/bot_profile.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:fren_app/widgets/processing.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:fren_app/widgets/store_products.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../widgets/rounded_top.dart';


class Step2Container extends StatefulWidget {
  final Bot bot;
  const Step2Container({Key? key, required this.bot}) : super(key: key);

  @override
  _Step2ContainerState createState() => _Step2ContainerState();
}

class _Step2ContainerState extends State<Step2Container> {

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          
            padding: const EdgeInsets.all(20),
            child: Column(
                children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 50),
                child: Text("${widget.bot.name} ${_i18n.translate('bot_prepub_headline')}",
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineSmall,
                    textAlign: TextAlign.left),
              ),
                  BotProfileCard(bot: widget.bot),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text("${widget.bot.name} ${_i18n.translate('bot_prepublish')}",
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium,
                        textAlign: TextAlign.left),
                  ),
              const SizedBox(height: 20),

              ElevatedButton(
                child: Text(_i18n.translate('bot_test')),
                onPressed: () {},
              ),
            ])
        ),
      ),
    );
  }
}

