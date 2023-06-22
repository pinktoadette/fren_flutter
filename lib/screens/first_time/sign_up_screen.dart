import 'package:google_fonts/google_fonts.dart';
import 'package:machi_app/api/machi/user_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/first_time/first_time_user.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/terms_of_service_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:scoped_model/scoped_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  final _userApi = UserApi();

  /// User Birthday info
  int _userBirthDay = 0;
  int _userBirthMonth = 0;
  int _userBirthYear = DateTime.now().subtract(const Duration(days: 4745)).year;
  // End
  DateTime _initialDateTime =
      DateTime.now().subtract(const Duration(days: 4745));
  String? _birthday;
  bool _agreeTerms = true;
  late AppLocalizations _i18n;
  TextStyle textStyle = GoogleFonts.poppins(
      fontSize: 16, color: Colors.black, fontWeight: FontWeight.normal);
  TextStyle dimmedStyle = GoogleFonts.poppins(
      fontSize: 16, color: Colors.grey, fontWeight: FontWeight.normal);
  @override
  void initState() {
    super.initState();
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
        confirm: Text(_i18n.translate('DONE'), style: textStyle),
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
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      body: ScopedModelDescendant<UserModel>(
          builder: (context, child, userModel) {
        /// Check loading status
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                  height: height * 0.5,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_i18n.translate('sign_up'),
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.left),
                        const SizedBox(height: 20),
                        Image.asset(
                          "assets/images/logo.png",
                          width: 200,
                        ),
                      ],
                    ),
                  )),
              Card(
                  child: Container(
                color: Colors.white,
                height: height * 0.5,
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 20),

                      /// FullName field
                      TextFormField(
                        cursorColor: Colors.black,
                        style: textStyle,
                        textCapitalization: TextCapitalization.sentences,
                        controller: _nameController,
                        decoration: InputDecoration(
                            errorBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 0.0),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 0.0),
                            ),
                            labelText: _i18n.translate("username"),
                            labelStyle: const TextStyle(
                                color: Color.fromARGB(255, 26, 25, 25)),
                            hintText: _i18n.translate("name_hint"),
                            hintStyle: dimmedStyle,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 20.0, right: 30),
                              child: Icon(
                                Iconsax.user,
                                color: Colors.grey,
                              ),
                            )),
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
                      ),
                      const SizedBox(height: 20),

                      /// Birthday card
                      Container(
                          color: Colors.white,
                          child: ListTile(
                            leading: const Icon(
                              Iconsax.gift,
                              color: Colors.grey,
                            ),
                            title: Text(_birthday!,
                                style: _userBirthMonth != 0
                                    ? textStyle
                                    : dimmedStyle),
                            trailing: const Icon(Icons.arrow_drop_down),
                            onTap: () {
                              FocusScope.of(context).unfocus();

                              /// Select birthday
                              _showDatePicker();
                            },
                          )),

                      const Spacer(),
                      if (userModel.isLoading)
                        const Center(child: Frankloader()),
                      SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black),
                            child: Text(
                              _i18n.translate("register"),
                              style: const TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              _createAccount();
                            },
                          )),
                      const SizedBox(height: 20),
                      _agreePrivacy(),
                    ],
                  ),
                ),
              )),
            ],
          ),
        );
      }),
    );
  }

  /// Handle Create account
  void _createAccount() async {
    bool isNameAvail = await _userApi
        .checkUsername(_nameController.text.toLowerCase().replaceAll(' ', ''));

    if (!_agreeTerms) {
      // Show error message
      Get.snackbar(
        _i18n.translate("terms_condition"),
        _i18n.translate("you_must_agree_to_our_privacy_policy"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
    }

    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        _i18n.translate('validation_warning'),
        _i18n.translate("validation_3_characters"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_WARNING,
      );
    } else if (!isNameAvail) {
      Get.snackbar(
        _i18n.translate("validation_warning"),
        _i18n.translate("validation_username"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      return;
    } else if (UserModel().calculateUserAge(_initialDateTime) < 12) {
      Get.snackbar(
        'Must be 12+',
        _i18n.translate(
            "only_12_years_old_and_above_are_allowed_to_create_an_account"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_WARNING,
      );
    } else {
      /// Call all input onSaved method
      _formKey.currentState!.save();

      /// Call sign up method
      UserModel().signUp(
        isProfileFilled: true,
        userFullName: _nameController.text.trim(),
        userBirthDay: _userBirthDay,
        userBirthMonth: _userBirthMonth,
        userBirthYear: _userBirthYear,
        onSuccess: () async {
          Future(() {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const InterestScreen()),
                (route) => false);
          });
        },
        onFail: (error) async {
          // Debug error
          debugPrint(error);

          Get.snackbar(
            _i18n.translate("validation_warning"),
            _i18n.translate("an_error_occurred_while_creating_your_account"),
            snackPosition: SnackPosition.TOP,
            backgroundColor: APP_ERROR,
          );
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
                      style:
                          const TextStyle(fontSize: 10, color: Colors.black))),
              // Terms of Service and Privacy Policy
              TermsOfServiceRow(color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }
}
