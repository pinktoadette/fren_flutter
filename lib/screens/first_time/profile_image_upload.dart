import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/first_time/interest_screen.dart';
import 'package:machi_app/screens/first_time/steps_counter.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/image/image_generative.dart';
import 'package:machi_app/widgets/walkthru/walkthru.dart';

class ProfileImageGenerator extends StatefulWidget {
  const ProfileImageGenerator({Key? key}) : super(key: key);

  @override
  _ProfileImageGeneratorState createState() => _ProfileImageGeneratorState();
}

class _ProfileImageGeneratorState extends State<ProfileImageGenerator> {
  late AppLocalizations _i18n;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showWalkthru = false;
  bool _walkthruCompleted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            body: Container(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StepCounterSignup(step: 2),
                      Semantics(
                          label:
                              "${_i18n.translate("hello")} ${UserModel().user.username}, ${_i18n.translate("sign_up_step_2_title")}",
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "${_i18n.translate("hello")} ${UserModel().user.username}, ",
                                  style: const TextStyle(
                                      color: APP_ACCENT_COLOR, fontSize: 22),
                                ),
                                TextSpan(
                                  text: _i18n.translate("sign_up_step_2_title"),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      Semantics(
                          label:
                              "${_i18n.translate("sign_up_step_2_direction")} ${_i18n.translate("sign_up_profile_generate_once")}",
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: _i18n
                                      .translate("sign_up_step_2_direction"),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                TextSpan(
                                  text: _i18n.translate(
                                      "sign_up_profile_generate_once"),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Offstage(
                        offstage: !(!_walkthruCompleted && !_showWalkthru) &&
                            !(_walkthruCompleted && !_showWalkthru),
                        child: ImagePromptGeneratorWidget(
                          isProfile: true,
                          onButtonClicked: (onclick) {
                            setState(() {
                              _showWalkthru = onclick;
                            });
                          },
                          onImageSelected: (value) {
                            _saveSelectedPhoto(value);
                          },
                          onImageReturned: (bool onImages) {
                            setState(() {
                              _showWalkthru = !onImages;
                            });
                          },
                        ),
                      ),
                      Offstage(
                        offstage: !_showWalkthru,
                        child: WalkThruSteps(onCarouselCompletion: () {
                          _walkthruCompleted = true;
                        }),
                      ),
                      if (_showWalkthru)
                        TextButton.icon(
                            onPressed: null,
                            icon: loadingButton(
                                size: 16, color: APP_ACCENT_COLOR),
                            label: const Text("Generating images"))
                    ],
                  ),
                ))));
  }

  void _saveSelectedPhoto(String photoUrl) async {
    try {
      /// upload this image
      final _botApi = BotApi();
      String url =
          await _botApi.uploadImageUrl(uri: photoUrl, pathLocation: 'profile');

      /// upload to user model
      await UserModel().updateUserData(
          userId: UserModel().user.userId, data: {USER_PROFILE_PHOTO: url});
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const InterestScreen()),
          (route) => false);
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("Error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Error saving users profile', fatal: false);
    }
  }
}
