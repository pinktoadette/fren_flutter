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
import 'package:fren_app/screens/first_time/first_time_user.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:fren_app/widgets/processing.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:fren_app/widgets/store_products.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:scoped_model/scoped_model.dart';

import '../rounded_top.dart';


class BotProfileCard extends StatelessWidget {
  final Bot bot;
  final bool? showStatus;
  const BotProfileCard({Key? key, required this.bot, this.showStatus }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);
    return Center(
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28)),
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Iconsax.box_tick),
                title: Text("Name: ${bot.name}"),
                subtitle: Text("Domain: ${bot.domain} - ${bot.subdomain ?? "subdomain"}"),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(30),
                        child: Text("Price: ${bot.price ?? 0.00} \n\n${bot.about ?? ""}"),
                      )
                  ),
                ]
              ),
              if (showStatus == true) Row(
                children: [
                  Padding(padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(bot.isActive == false ? 'Unpublished': 'Published',
                            style: TextStyle(color: bot.isActive == false ? APP_ERROR : APP_SUCCESS )),
                            const SizedBox(width: 120),
                            bot.isActive == false ? ElevatedButton(
                                onPressed:() {
                                  Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => Step2Container()),
                                  );
                                },
                                child: const Text('Publish')
                            ):
                            OutlinedButton(
                                onPressed:() {
                                  Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => Step2Container()),
                                  );
                                },
                            child: const Text('Edit')
                        )
                      ],
                    ),
                  ),

                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

