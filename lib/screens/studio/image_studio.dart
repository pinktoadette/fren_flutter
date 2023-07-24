import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/first_time/interest_screen.dart';
import 'package:machi_app/widgets/image/image_generative.dart';
import 'package:machi_app/widgets/subscribe/subscribe_token_counter.dart';

class ImageStudioScreen extends StatefulWidget {
  const ImageStudioScreen({Key? key}) : super(key: key);

  @override
  _ImageStudioScreenState createState() => _ImageStudioScreenState();
}

class _ImageStudioScreenState extends State<ImageStudioScreen> {
  late AppLocalizations _i18n;
  final String _selectedUrl = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            _i18n.translate("studio"),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          actions: const [SubscribeTokenCounter()],
        ),
        body: SingleChildScrollView(
            child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _i18n.translate("studio_draw_prompt"),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: 10,
              ),
              ImagePromptGeneratorWidget(
                  onImageSelected: (value) => {_saveSelectedPhoto(value)}),
              const SizedBox(
                height: 100,
              )
            ],
          ),
        )));
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
          reason: 'Error saving users profile', fatal: true);
    }
  }
}
