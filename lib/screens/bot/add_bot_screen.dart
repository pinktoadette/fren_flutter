import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:fren_app/dialogs/progress_dialog.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/screens/bot/add_bot_step1.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:flutter/material.dart';

class AddBot extends StatefulWidget {
  const AddBot({Key? key}) : super(key: key);

  @override
  _AddBotState createState() => _AddBotState();
}

class _AddBotState extends State<AddBot> {
  final _formsPageViewController = PageController();
  late AppLocalizations _i18n;
  late ProgressDialog _pr;
  late List _steps = [];

  @override
  void initState() {
    super.initState();

  }

  bool onWillPop() {
    if (_formsPageViewController.page?.round() ==
        _formsPageViewController.initialPage) return true;

    _formsPageViewController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _steps = [
      WillPopScope(
        onWillPop: () => Future.sync(onWillPop),
        child: const Step0Container(),
      ),
      WillPopScope(
        onWillPop: () => Future.sync(onWillPop),
        child: const Step1Container(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
        children: const [Step0Container()]
        ))
    );
  }
}

class Step0Container extends StatelessWidget {
  const Step0Container({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);
    return Center(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(_i18n.translate('create_bot'),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.left),
          ),
          const Frankloader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Text(_i18n.translate('create_bot_des'),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.left),
          ),
          SignInButton(
            Buttons.GitHub,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            onPressed: () {
              //@todo make temporary form
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Step1Container()));
            },
          )
        ]));
  }
}



