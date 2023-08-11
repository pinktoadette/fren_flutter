import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/animations/desktop.dart';
import 'package:flutter/material.dart';

class AddBotScreen extends StatefulWidget {
  const AddBotScreen({Key? key}) : super(key: key);

  @override
  State<AddBotScreen> createState() => _AddBotState();
}

class _AddBotState extends State<AddBotScreen> {
  late AppLocalizations _i18n;

  bool loader = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(50),
                child: Column(children: [
                  const SizedBox(
                    height: 40,
                  ),
                  const DesktopAnimation(),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(_i18n.translate('create_bot'),
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.left),
                  ),
                  Text(_i18n.translate('create_bot_des'),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left),
                  const Spacer(),
                  SignInButton(
                    text: _i18n.translate("login_from_desktop"),
                    Buttons.GitHub,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    onPressed: () {
                      null;
                    },
                  ),
                  const SizedBox(
                    height: 100,
                  )
                ]))));
  }

  void onClickGitHubLoginButton() async {}
}
