import 'package:flutter/services.dart';
import 'package:machi_app/api/machi/user_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/first_time/profile_image_upload.dart';
import 'package:machi_app/screens/first_time/steps_counter.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/terms_of_service_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  final _userApi = UserApi();
  late AppLocalizations _i18n;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Initialization
    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    // @todo should really be loop by step
    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      body: ScopedModelDescendant<UserModel>(
          builder: (context, child, userModel) {
        return Container(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const StepCounterSignup(step: 1),
              Semantics(
                label: _i18n.translate("sign_up_step_1_title"),
                child: Text(_i18n.translate("sign_up_step_1_title"),
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              const SizedBox(
                height: 20,
              ),
              Form(
                  key: _formKey,
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      labelText: _i18n.translate("username"),
                      hintText: _i18n.translate("name_hint"),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              APP_INVERSE_PRIMARY_COLOR, // Customize the color here
                        ),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                    ],
                    validator: (name) {
                      // Basic validation
                      if (name?.isEmpty ?? false) {
                        return _i18n.translate("enter_your_fullname");
                      }
                      if (name != null && name.length < 3) {
                        return _i18n.translate("validation_3_characters");
                      }
                      return null;
                    },
                  )),
              const Spacer(),
              TextButton.icon(
                  onPressed: _createAccount,
                  icon: isLoading == true
                      ? loadingButton(size: 16, color: APP_ACCENT_COLOR)
                      : const SizedBox.shrink(),
                  label: Text(
                    _i18n.translate("register"),
                    style: const TextStyle(color: Colors.white),
                  )),
              const SizedBox(height: 20),
              _agreePrivacy(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    ));
  }

  /// Handle Create account
  void _createAccount() async {
    setState(() {
      isLoading = true;
    });
    bool isNameAvail = await _userApi
        .checkUsername(_nameController.text.toLowerCase().replaceAll(' ', ''));

    if (!_formKey.currentState!.validate()) {
      Get.snackbar(_i18n.translate('validation_warning'),
          _i18n.translate("validation_3_characters"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_WARNING,
          colorText: Colors.black);
      setState(() {
        isLoading = false;
      });
    } else if (isNameAvail == false) {
      Get.snackbar(_i18n.translate("validation_warning"),
          _i18n.translate("validation_username"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_WARNING,
          colorText: Colors.black);
      setState(() {
        isLoading = false;
      });
    } else {
      /// Call all input onSaved method
      _formKey.currentState!.save();

      /// Call sign up method
      UserModel()
          .signUp(
        isProfileFilled: true,
        userFullName: _nameController.text.trim(),
        userBirthDay: 1,
        userBirthMonth: 1,
        userBirthYear: 2000,
        onSuccess: () async {
          Future(() {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const ProfileImageGenerator()),
                (route) => false);
          });
        },
        onFail: (error) async {
          Get.snackbar(_i18n.translate("validation_warning"),
              _i18n.translate("an_error_occurred_while_creating_your_account"),
              snackPosition: SnackPosition.TOP,
              backgroundColor: APP_ERROR,
              colorText: Colors.black);
        },
      )
          .whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Handle Agree privacy policy
  Widget _agreePrivacy() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(_i18n.translate("i_agree_with"),
                  style: const TextStyle(fontSize: 10)),
              // Terms of Service and Privacy Policy
              TermsOfServiceRow(),
            ],
          ),
        ],
      ),
    );
  }
}
