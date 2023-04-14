import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:fren_app/widgets/processing.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/button/default_button.dart';
import 'package:iconsax/iconsax.dart';
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
        onWillPop: () => Future.sync(onWillPop),
        child: const Step1Container(),
      ),
      WillPopScope(
        onWillPop: () => Future.sync(onWillPop),
        child: const Step2Container(),
      ),
    ];

    return Expanded(
      child: PageView.builder(
        controller: _formsPageViewController,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return _forms[index];
        },
      ),
    );
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
}

class Step1Container extends StatelessWidget {
  const Step1Container({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _bioController = TextEditingController();

    return Scaffold(
      body: ScopedModelDescendant<UserModel>(
          builder: (context, child, userModel) {
        /// Check loading status
        if (userModel.isLoading) return const Processing();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              Frankloader(),
              Text(_i18n.translate('intro_1'),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(_i18n.translate('intro_2')),
              const SizedBox(height: 50),
              Text(_i18n.translate('intro_quick_start')),

              const SizedBox(height: 50),

              /// Form
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    /// FullName field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          labelText: _i18n.translate("fullname"),
                          hintText: _i18n.translate("enter_your_fullname"),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(Iconsax.user),
                          )),
                      validator: (name) {
                        // Basic validation
                        if (name?.isEmpty ?? false) {
                          return _i18n.translate("please_enter_your_fullname");
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    /// Bio field
                    TextFormField(
                      controller: _bioController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: _i18n.translate("bio"),
                        hintText: _i18n.translate("please_write_your_bio"),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Icon(Iconsax.information),
                        ),
                      ),
                      validator: (bio) {
                        if (bio?.isEmpty ?? false) {
                          return _i18n.translate("please_write_your_bio");
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    /// Sign Up button
                    SizedBox(
                      width: double.maxFinite,
                      child: DefaultButton(
                        child: Text(_i18n.translate("next_step"),
                            style: const TextStyle(fontSize: 18)),
                        onPressed: () {
                          /// Sign up
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const Step2Container()),
                              (route) => false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class Step2Container extends StatelessWidget {
  const Step2Container({Key? key}) : super(key: key);

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
