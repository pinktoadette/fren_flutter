import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/home_screen.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:fren_app/widgets/terms_of_service_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:flutter/services.dart' show rootBundle;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();

  /// User Birthday info
  int _userBirthDay = 0;
  int _userBirthMonth = 0;
  int _userBirthYear = DateTime.now().subtract(const Duration(days: 7300)).year;
  // End
  DateTime _initialDateTime =
      DateTime.now().subtract(const Duration(days: 7300));
  String? _birthday;
  bool _agreeTerms = true;
  String? _selectedIndustry;
  List<String> _selectedInterest = ['Animals and Pets'];
  late List<String> _interestList = [];
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
    getJson();
  }

  Future<void> getJson() async {
    String _inter = await rootBundle.loadString('assets/json/interest.json');
    List<String> interestList = List.from(jsonDecode(_inter) as List<dynamic>);

    setState(() {
      _interestList = interestList;
    });
  }

  /// Set terms
  void _setAgreeTerms(bool value) {
    setState(() {
      _agreeTerms = value;
    });
  }

  void _updateUserBithdayInfo(DateTime date) {
    setState(() {
      // Update the inicial date
      _initialDateTime = date;
      // Set for label
      _birthday = date.toString().split(' ')[0];
      // User birthday info
      _userBirthDay = date.day;
      _userBirthMonth = date.month;
      _userBirthYear = date.year;
    });
  }

  // Get Date time picker app locale
  DateTimePickerLocale _getDatePickerLocale() {
    DateTimePickerLocale _locale = DateTimePickerLocale.en_us;
    // Get the name of the current locale.
    switch (_i18n.translate('lang')) {
      // Handle your Supported Languages below:
      case 'en': // English
        _locale = DateTimePickerLocale.en_us;
        break;
    }
    return _locale;
  }

  /// Display date picker.
  void _showDatePicker() {
    DatePicker.showDatePicker(
      context,
      onMonthChangeStartWithFirstDate: true,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text(_i18n.translate('DONE'),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Theme.of(context).primaryColor)),
      ),
      minDateTime: DateTime(1920, 1, 1),
      maxDateTime: DateTime.now(),
      initialDateTime: _initialDateTime,
      dateFormat: 'yyyy-MMMM-dd', // Date format
      locale: _getDatePickerLocale(), // Set your App Locale here
      onClose: () => debugPrint("----- onClose -----"),
      onCancel: () => debugPrint('onCancel'),
      onChange: (dateTime, List<int> index) {
        // Get birthday info
        _updateUserBithdayInfo(dateTime);
      },
      onConfirm: (dateTime, List<int> index) {
        // Get birthday info
        _updateUserBithdayInfo(dateTime);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Initialization
    _i18n = AppLocalizations.of(context);
    _birthday = _i18n.translate("select_your_birthday");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ScopedModelDescendant<UserModel>(
          builder: (context, child, userModel) {
        /// Check loading status
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 50),
              Text(_i18n.translate('sign_up'),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.left),
              Padding(
                padding: const EdgeInsets.all(25),

                /// Form
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      /// FullName field
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: _nameController,
                        decoration: InputDecoration(
                            labelText: _i18n.translate("fullname"),
                            hintText: _i18n.translate("name_hint"),
                            hintStyle: const TextStyle(color: Colors.grey),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Icon(Iconsax.user),
                            )),
                        validator: (name) {
                          // Basic validation
                          if (name?.isEmpty ?? false) {
                            return _i18n.translate("enter_your_fullname");
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      /// Birthday card
                      Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.grey)),
                          child: ListTile(
                            leading: const Icon(Iconsax.cake),
                            title: Text(_birthday!,
                                style: Theme.of(context).textTheme.labelMedium),
                            trailing: const Icon(Icons.arrow_drop_down),
                            onTap: () {
                              FocusScope.of(context).unfocus();

                              /// Select birthday
                              _showDatePicker();
                            },
                          )),
                      const SizedBox(height: 20),

                      /// User interest
                      const Text("What are your interest? Select 3.",
                          style: TextStyle(color: Colors.grey)),

                      if (_interestList.isNotEmpty)
                        SizedBox(
                            child: SingleChildScrollView(
                          child: ChipsChoice<String>.multiple(
                            value: _selectedInterest,
                            onChanged: (val) => {
                              setState(() {
                                _selectedInterest = val;
                              })
                            },
                            choiceItems: C2Choice.listFrom<String, String>(
                              source: _interestList,
                              value: (i, v) => v,
                              label: (i, v) => v,
                              tooltip: (i, v) => v,
                            ),
                            choiceCheckmark: true,
                            choiceStyle: C2ChipStyle.outlined(),
                            wrapped: true,
                          ),
                        )),

                      const SizedBox(height: 20),
                      if (userModel.isLoading)
                        const CircularProgressIndicator(),
                      SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            child: Container(
                                color: Theme.of(context).colorScheme.primary,
                                child: Text(_i18n.translate("register"),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background))),
                            onPressed: () {
                              _createAccount();
                            },
                          )),
                      const SizedBox(height: 20),
                      _agreePrivacy(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Handle Create account
  void _createAccount() async {
    if (_selectedInterest.length < 3) {
      Get.snackbar(
        'Select 3 Items',
        _i18n.translate("select_three_interest"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    } else if (!_agreeTerms) {
      // Show error message
      Get.snackbar(
        'Terms and Condition',
        _i18n.translate("you_must_agree_to_our_privacy_policy"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );

      /// Validate form
    } else if (UserModel().calculateUserAge(_initialDateTime) < 18) {
      // Show error message
      Get.snackbar(
        'Must be 18+',
        _i18n.translate(
            "only_18_years_old_and_above_are_allowed_to_create_an_account"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    } else if (!_formKey.currentState!.validate()) {
    } else {
      /// Call all input onSaved method
      _formKey.currentState!.save();

      /// Call sign up method
      UserModel().signUp(
        isProfileFilled: true,
        userFullName: _nameController.text.trim(),
        userInterest: _selectedInterest,
        userBirthDay: _userBirthDay,
        userBirthMonth: _userBirthMonth,
        userBirthYear: _userBirthYear,
        onSuccess: () async {
          Future(() {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false);
          });
        },
        onFail: (error) async {
          // Debug error
          debugPrint(error);

          showScaffoldMessage(
              message: _i18n
                  .translate("an_error_occurred_while_creating_your_account"),
              bgcolor: APP_ACCENT_COLOR);

          // await _errorLogged.postError(
          //     errorMessage: error,
          //     errorLocation: "sign up screen - creating account");
        },
      );
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
              GestureDetector(
                  onTap: () => _setAgreeTerms(!_agreeTerms),
                  child: Text(_i18n.translate("i_agree_with"),
                      style: const TextStyle(fontSize: 10))),
              // Terms of Service and Privacy Policy
              TermsOfServiceRow(color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }
}
