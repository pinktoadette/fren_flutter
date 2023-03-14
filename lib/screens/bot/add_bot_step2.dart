import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chat_controller.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/bot_model.dart';
import 'package:fren_app/screens/bot/bot_chat.dart';
import 'package:fren_app/screens/bot/manage_bot_screen.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:get/get.dart';

class Step2CreateBot extends StatelessWidget {
  final BotController botController = Get.find();
  final ChatController chatController = Get.find();

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);

    Future<void> _publishBot() async {
        BotModel().updateBotData(
            botId: botController.bot.botId,
            data: { BOT_ACTIVE: true},
            onSuccess: () async {
              // Show success message
              successDialog(context,
                  message:
                  _i18n.translate("Success"),
                  positiveAction: () {

                    Future(() {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const ManageBotScreen()),
                              (route) => false);
                    });
                    // End
                  });
            },
            onError: (error) {
              // Debug error
              debugPrint(error);
              // Show error message
              showScaffoldMessage(
                  context: context,
                  message: _i18n.translate("an_error_has_occurred"),
                  bgcolor: Colors.pinkAccent);
        }
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            chatController.isTest = false;
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
                child: Text("${botController.bot.name} ${_i18n.translate('bot_prepub_headline')}",
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineSmall,
                    textAlign: TextAlign.left),
              ),
                  BotProfileCard(bot: botController.bot),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text("${botController.bot.name} ${_i18n.translate('bot_prepublish')}",
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium,
                        textAlign: TextAlign.left),
                  ),
              const SizedBox(height: 20),
                  ElevatedButton(
                    child: Text(_i18n.translate('bot_test')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      elevation: 2,
                    ),
                    onPressed: () {
                      chatController.isTest = true;
                      Future(() {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const BotChatScreen() ));
                      });
                    },
                  ),
              const Spacer(),
              SizedBox(
              width: 250.0,
              child: ElevatedButton(
                    child: Text(_i18n.translate('publish')),
                    onPressed: () {
                      _publishBot();
                    },
                  )),
            ])
        ),
      ),
    );
    }
}

