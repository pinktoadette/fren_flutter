import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/services.dart';
import 'package:fren_app/dialogs/progress_dialog.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/widgets/avatar_initials.dart';
import 'package:fren_app/widgets/image_source_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../constants/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Variables
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _bioController = TextEditingController(text: UserModel().user.userBio);

  late String _selectedIndustry;
  late List<String> _selectedInterest;
  late List<String> _interestList = [];

  late AppLocalizations _i18n;
  late ProgressDialog _pr;

  @override
  void initState() {
    super.initState();
    getJson();
    setState(() {
      _selectedIndustry = UserModel().user.userIndustry;
      _selectedInterest = UserModel().user.userInterest;
    });
  }

  Future<void> getJson() async {
    String _indu = await rootBundle.loadString('assets/json/industry.json');
    List<String> industryList = List.from(jsonDecode(_indu) as List<dynamic>);

    String _inter = await rootBundle.loadString('assets/json/interest.json');
    List<String> interestList = List.from(jsonDecode(_inter) as List<dynamic>);

    setState(() {
      _interestList = interestList;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context, isDismissible: false);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_i18n.translate("edit_profile")),
        actions: [
          // Save changes button
          TextButton(
            child: Text(_i18n.translate("SAVE")),
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());

              /// Validate form
              if (_formKey.currentState!.validate()) {
                _saveChanges();
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: ScopedModelDescendant<UserModel>(
              builder: (context, child, userModel) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Profile photo
                GestureDetector(
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        AvatarInitials(
                          userId: userModel.user.userId,
                          photoUrl: userModel.user.userProfilePhoto,
                          username: userModel.user.username,
                        ),

                        /// Edit icon
                        Positioned(
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(
                              Icons.edit,
                              color: Theme.of(context).colorScheme.background,
                              size: 12,
                            ),
                          ),
                          right: 0,
                          bottom: 0,
                        ),
                      ],
                    ),
                  ),
                  onTap: () async {
                    /// Update profile image
                    _selectImage(
                        imageUrl: userModel.user.userProfilePhoto,
                        path: 'profile');
                  },
                ),

                /// Bio field
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: _bioController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      labelText: _i18n.translate("bio"),
                      hintText: _i18n.translate("write_about_you"),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    validator: (bio) {
                      if (bio == null) {
                        return _i18n.translate("please_write_your_bio");
                      }
                      return null;
                    },
                  ),
                ),

                /// interest
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
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Get image from camera / gallery
  void _selectImage({required String imageUrl, required String path}) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) => ImageSourceSheet(
              onImageSelected: (image) async {
                if (image != null) {
                  /// Show progress dialog
                  _pr.show(_i18n.translate("processing"));

                  /// Update profile image
                  await UserModel().updateProfileImage(
                      imageFile: image, oldImageUrl: imageUrl, path: 'profile');
                  // Hide dialog
                  _pr.hide();
                  // close modal
                  Navigator.of(context).pop();
                }
              },
            ));
  }

  /// Update profile changes for TextFormField only
  void _saveChanges() {
    /// Update uer profile
    UserModel().updateProfile(
        userIndustry: _selectedIndustry,
        interests: _selectedInterest,
        userBio: _bioController.text.trim(),
        onSuccess: () async {
          /// Show success message
          Get.snackbar(
            'Success',
            _i18n.translate("profile_updated_successfully"),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: APP_SUCCESS,
          );
        },
        onFail: (error) {
          // Debug error
          debugPrint(error);
          // Show error message
          Get.snackbar(
            'Error',
            _i18n.translate("an_error_occurred_while_updating_your_profile"),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: APP_ERROR,
          );
        });
  }
}
