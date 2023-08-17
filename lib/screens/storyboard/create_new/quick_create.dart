import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/dialogs/progress_dialog.dart';
import 'package:machi_app/helpers/app_helper.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/screens/storyboard/storyboard_home.dart';

class QuickCreateNewBoard extends StatefulWidget {
  const QuickCreateNewBoard({Key? key}) : super(key: key);

  @override
  State<QuickCreateNewBoard> createState() => _QuickCreateNewBoardState();
}

class _QuickCreateNewBoardState extends State<QuickCreateNewBoard> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  late AppLocalizations _i18n;
  final TextEditingController _aboutController = TextEditingController();
  final _storyApi = StoryApi();
  late ProgressDialog _pr;
  final _appHelper = AppHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    TextStyle? styleLabel = Theme.of(context).textTheme.labelMedium;
    TextStyle? styleBody = Theme.of(context).textTheme.bodyMedium;
    _pr = ProgressDialog(context, isDismissible: true);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          titleSpacing: 0,
          centerTitle: false,
          title: Text(
            _i18n.translate("creative_mix_help_me"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_i18n.translate("creative_mix_quick_description"),
                  style: styleLabel),
              Text(_i18n.translate("creative_mix_quick_sub_desc"),
                  style: styleBody),
              TextFormField(
                onTapOutside: (b) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                style: styleBody,
                controller: _aboutController,
                maxLength: 300,
                maxLines: 10,
                decoration: InputDecoration(
                    hintText: _i18n.translate("creative_mix_quick_hint"),
                    hintStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    floatingLabelBehavior: FloatingLabelBehavior.always),
                validator: (reason) {
                  if (reason?.isEmpty ?? false) {
                    return _i18n.translate("creative_mix_quick_hint");
                  }
                  return null;
                },
              ),
              const Spacer(),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                      onPressed: () {
                        _updateChanges();
                      },
                      child: Text(_i18n.translate("creative_mix_create")))),
              const SizedBox(
                height: 80,
              ),
              GestureDetector(
                child: Text(
                  _i18n.translate("bot_test_warning"),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                onTap: () {
                  // Open terms of service page in browser
                  _appHelper.openTermsPage();
                },
              ),
            ],
          ),
        ));
  }

  void _updateChanges() async {
    _pr.show(_i18n.translate("thinking"));

    try {
      Storyboard storyboard = await _storyApi.quickStory(_aboutController.text);
      storyboardController.addNewStoryboard(storyboard);

      _pr.hide();
      Get.back();

      Get.to(() => const StoryboardHome());
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Error creating quick board', fatal: true);
    } finally {
      _pr.hide();
    }
  }
}
