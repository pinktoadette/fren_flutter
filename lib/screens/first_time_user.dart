import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/sign_in_screen.dart';
import 'package:fren_app/screens/update_location_sceen.dart';
import 'package:fren_app/widgets/image_source_sheet.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:fren_app/widgets/processing.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:fren_app/widgets/svg_icon.dart';
import 'package:fren_app/widgets/terms_of_service_row.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/default_button.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:scoped_model/scoped_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterScreen> {
  final _formsPageViewController = PageController();
  late List _forms;

  @override
  Widget build(BuildContext context) {
    _forms = [
      WillPopScope(
        onWillPop: () => Future.sync(this.onWillPop),
        child: Step1Container(),
      ),
      WillPopScope(
        onWillPop: () => Future.sync(this.onWillPop),
        child: Step2Container(),
      ),
    ];

    return Expanded(
      child: PageView.builder(
        controller: _formsPageViewController,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return _forms[index];
        },
      ),
    );
  }

  void _nextFormStep() {
    _formsPageViewController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  bool onWillPop() {
    if (_formsPageViewController.page?.round() ==
        _formsPageViewController.initialPage) return true;

    _formsPageViewController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );

    return false;
  }
}

class Step1Container extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final i18n = AppLocalizations.of(context);
    final _nameController = TextEditingController();
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  const LottieLoader(),
                  Text(i18n.translate('intro_1')),
                  Text(i18n.translate('intro_2')),
                  Text(i18n.translate('intro_3')),
                  Text(i18n.translate('intro_4')),
                  Text(i18n.translate('intro_fullname')),
                  Form(
                    // key: _formKey,
                    child: Column(
                      children: <Widget>[

                        /// FullName field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                              labelText: i18n.translate("fullname"),
                              hintText: i18n.translate(
                                  "enter_your_fullname"),
                              floatingLabelBehavior: FloatingLabelBehavior
                                  .always,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SvgIcon(
                                    "assets/icons/user_icon.svg"),
                              )),
                          validator: (name) {
                            // Basic validation
                            if (name?.isEmpty ?? false) {
                              return i18n.translate(
                                  "please_enter_your_fullname");
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ]
            )
        )
    );
  }
}

class Step2Container extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(i18n.translate('intro_professional_service')),
            OutlinedButton(
              child: Text(i18n.translate('Done')),
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return const RegisterScreen();
                    },
                  ),
                );
              },
            ),
            const Text('Push to a new screen, then tap on shouldPop '
                'button to toggle its value. Press the back '
                'button in the appBar to check its behavior '
                'for different values of shouldPop'),
          ],
        ),
      ),
    );
  }
}
