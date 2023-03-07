import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/screens/chat_bot.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:flutter/material.dart';

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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  elevation: 0,
                ),
                onPressed: () {
                  Future(() {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => BotChatScreen(bot:widget.bot)));
                  });
                },
              ),
              const Spacer(),
              ElevatedButton(
                child: Text(_i18n.translate('publish')),
                onPressed: () {

                    },
                ),
            ])
        ),
      ),
    );
  }
}

