import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/constants/secrets.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/widgets/animations/desktop.dart';
import 'package:fren_app/widgets/animations/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AddBotScreen extends StatefulWidget {
  const AddBotScreen({Key? key}) : super(key: key);

  @override
  _AddBotState createState() => _AddBotState();
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
            child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(_i18n.translate('create_bot'),
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.left),
          ),
          const DesktopAnimation(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Text(_i18n.translate('create_bot_des'),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.left),
          ),
          const Spacer(),
          SignInButton(
            text: "Login in from Desktop",
            Buttons.GitHub,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            onPressed: () {
              null;
            },
          )
        ])));
  }

  void onClickGitHubLoginButton() async {
    Uri url = Uri(
        scheme: 'https',
        host: 'github.com',
        path: '/login/oauth/authorize',
        queryParameters: {
          'client_id': GITHUB_CLIENT_ID,
          'scope': 'public_repo'
        });
    print(url);
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
      );
    } else {
      Get.snackbar(
        'Error',
        'Unable to launch URL',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }
}
