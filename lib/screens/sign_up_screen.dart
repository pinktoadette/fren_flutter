import 'dart:io';

import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/sign_in_screen.dart';
import 'package:fren_app/screens/update_location_sceen.dart';
import 'package:fren_app/widgets/image_source_sheet.dart';
import 'package:fren_app/widgets/processing.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:fren_app/widgets/svg_icon.dart';
import 'package:fren_app/widgets/terms_of_service_row.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/default_button.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/rounded_top.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Variables
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _jobController = TextEditingController();
  final _bioController = TextEditingController();

  /// User Birthday info
  int _userBirthDay = 0;
  int _userBirthMonth = 0;
  int _userBirthYear = DateTime.now().year;
  // End
  DateTime _initialDateTime = DateTime.now();
  String? _birthday;
  File? _imageFile;
  bool _agreeTerms = true;
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Non-Binary'];
  late AppLocalizations _i18n;

  /// Set terms
  void _setAgreeTerms(bool value) {
    setState(() {
      _agreeTerms = value;
    });
  }

  /// Get image from camera / gallery
  void _getImage(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ImageSourceSheet(
              onImageSelected: (image) {
                if (image != null) {
                  setState(() {
                    _imageFile = image;
                  });
                  // close modal
                  Navigator.of(context).pop();
                }
              },
            ));
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
    // Inicial value
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
                fontSize: 18.0,
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
        if (userModel.isLoading) return const Processing();
        return SingleChildScrollView(
          // padding: const EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              const RoundedTop(),

              /// Profile photo
              GestureDetector(
                child: Center(
                    child: _imageFile == null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: const AssetImage("assets/images/frank1.png"),
                            child: Stack(
                                children: const [
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white70,
                                      child: Icon(Iconsax.camera),
                                    ),
                                  ),
                                ]
                            ),
                          )
                        : CircleAvatar(
                            radius: 60,
                            backgroundImage: FileImage(_imageFile!),
                          )),
                onTap: () {
                  /// Get profile image
                  _getImage(context);
                },
              ),
              Text(_i18n.translate("create_account"),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),

              const SizedBox(height: 22),

              Padding(
                padding: const EdgeInsets.all(50),
                /// Form
                child: Form(
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
                              child: const Icon(Iconsax.user),
                            )
                        ),
                        validator: (name) {
                          // Basic validation
                          if (name?.isEmpty ?? false) {
                            return _i18n.translate("please_enter_your_fullname");
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      /// User gender
                      DropdownButtonFormField<String>(
                        items: _genders.map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: _i18n.translate("lang") != 'en'
                                ? Text(
                                '${gender.toString()} - ${_i18n.translate(gender.toString().toLowerCase())}')
                                : Text(gender.toString()),
                          );
                        }).toList(),
                        hint: Text(_i18n.translate("select_gender")),
                        onChanged: (gender) {
                          setState(() {
                            _selectedGender = gender;
                          });
                        },
                        validator: (String? value) {
                          if (value == null) {
                            return _i18n.translate("please_select_your_gender");
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      /// Birthday card
                      Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                              side: BorderSide(color: Colors.grey[350] as Color)),
                          child: ListTile(
                            leading:
                            const SvgIcon("assets/icons/calendar_icon.svg"),
                            title: Text(_birthday!,
                                style: const TextStyle(color: Colors.grey)),
                            trailing: const Icon(Icons.arrow_drop_down),
                            onTap: () {
                              /// Select birthday
                              _showDatePicker();
                            },
                          )),
                      const SizedBox(height: 20),

                      // /// School field
                      // TextFormField(
                      //   controller: _schoolController,
                      //   decoration: InputDecoration(
                      //       labelText: _i18n.translate("school"),
                      //       hintText: _i18n.translate("enter_your_school_name"),
                      //       floatingLabelBehavior: FloatingLabelBehavior.always,
                      //       prefixIcon: const Padding(
                      //         padding: EdgeInsets.all(9.0),
                      //         child: SvgIcon("assets/icons/university_icon.svg"),
                      //       )),
                      // ),
                      // const SizedBox(height: 20),
                      //
                      // /// Job title field
                      // TextFormField(
                      //   controller: _jobController,
                      //   decoration: InputDecoration(
                      //       labelText: _i18n.translate("job_title"),
                      //       hintText: _i18n.translate("enter_your_job_title"),
                      //       floatingLabelBehavior: FloatingLabelBehavior.always,
                      //       prefixIcon: const Padding(
                      //         padding: EdgeInsets.all(12.0),
                      //         child: SvgIcon("assets/icons/job_bag_icon.svg"),
                      //       )),
                      // ),
                      // const SizedBox(height: 20),
                      //
                      // /// Bio field
                      // TextFormField(
                      //   controller: _bioController,
                      //   maxLines: 4,
                      //   decoration: InputDecoration(
                      //     labelText: _i18n.translate("bio"),
                      //     hintText: _i18n.translate("please_write_your_bio"),
                      //     floatingLabelBehavior: FloatingLabelBehavior.always,
                      //     prefixIcon: const Padding(
                      //       padding: EdgeInsets.all(12.0),
                      //       child: SvgIcon("assets/icons/info_icon.svg"),
                      //     ),
                      //   ),
                      //   validator: (bio) {
                      //     if (bio?.isEmpty ?? false) {
                      //       return _i18n.translate("please_write_your_bio");
                      //     }
                      //     return null;
                      //   },
                      // ),

                      _agreePrivacy(),
                      const SizedBox(height: 50),

                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          child: Container(
                              color: Theme.of(context).colorScheme.primary,
                              child: Text(_i18n.translate("register"),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).colorScheme.background))
                          ),
                          onPressed: () {
                            _createAccount();
                          },
                        )
                      ),
                      /// Sign Up button
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
    /// check image file
    if (_imageFile == null) {
      // Show error message
      showScaffoldMessage(
          context: context,
          message: _i18n.translate("please_select_your_profile_photo"),
          bgcolor: Colors.pinkAccent);
      // validate terms
    } else if (!_agreeTerms) {
      // Show error message
      showScaffoldMessage(
          context: context,
          message: _i18n.translate("you_must_agree_to_our_privacy_policy"),
          bgcolor: Colors.pinkAccent);

      /// Validate form
    } else if (UserModel().calculateUserAge(_initialDateTime) < 18) {
      // Show error message
      showScaffoldMessage(
          context: context,
          duration: const Duration(seconds: 7),
          message: _i18n.translate(
              "only_18_years_old_and_above_are_allowed_to_create_an_account"),
          bgcolor: Colors.pinkAccent);
    } else if (!_formKey.currentState!.validate()) {
    } else {
      /// Call all input onSaved method
      _formKey.currentState!.save();

      /// Call sign up method
      UserModel().signUp(
        isProfileFilled: true,
        userPhotoFile: _imageFile!,
        userFullName: _nameController.text.trim(),
        userGender: _selectedGender!,
        userBirthDay: _userBirthDay,
        userBirthMonth: _userBirthMonth,
        userBirthYear: _userBirthYear,
        onSuccess: () async {
          // Show success message
          successDialog(context,
              message:
                  _i18n.translate("your_account_has_been_created_successfully"),
              positiveAction: () {
            // Execute action
            // Go to get the user device's current location
            Future(() {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const UpdateLocationScreen()),
                  (route) => false);
            });
            // End
          });
        },
        onFail: (error) {
          // Debug error
          debugPrint(error);
          // Show error message
          errorDialog(context,
              message: _i18n
                  .translate("an_error_occurred_while_creating_your_account"));
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
                      style: const TextStyle(fontSize: 12))),
              // Terms of Service and Privacy Policy
              TermsOfServiceRow(color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }
}
