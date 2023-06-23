import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/dialogs/progress_dialog.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/common/avatar_initials.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

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

  late AppLocalizations _i18n;
  late ProgressDialog _pr;

  @override
  void initState() {
    super.initState();
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    /// Profile photo
                    GestureDetector(
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
                      onTap: () async {
                        /// Update profile image
                        _selectImage(
                            imageUrl: userModel.user.userProfilePhoto,
                            path: 'profile');
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),

                    /// username
                    Text(
                      UserModel().user.username,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),

                /// Bio field
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: _bioController,
                    maxLines: 10,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: _i18n.translate("write_your_bio"),
                    ),
                  ),
                ),
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
              onGallerySelected: (imageUrl) async {
                await UserModel().updateProfileWithAiGallery(imageUrl);
                Navigator.of(context).pop();
              },
            ));
  }

  /// Update profile changes for TextFormField only
  void _saveChanges() {
    /// Update uer profile
    UserModel().updateProfile(
        userBio: _bioController.text.trim(),
        onSuccess: () async {
          /// Show success message
          Get.snackbar(
              _i18n.translate("success"), _i18n.translate("update_successful"),
              snackPosition: SnackPosition.TOP,
              backgroundColor: APP_SUCCESS,
              colorText: Colors.black);
        },
        onFail: (error) {
          // Debug error
          debugPrint(error);
          // Show error message
          Get.snackbar(
            'Error',
            _i18n.translate("an_error_occurred_while_updating_your_profile"),
            snackPosition: SnackPosition.TOP,
            backgroundColor: APP_ERROR,
          );
        });
  }
}
