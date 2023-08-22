import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/dialogs/progress_dialog.dart';
import 'package:machi_app/helpers/app_helper.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/screens/storyboard/page/page_view.dart';

class QuickCreateNewBoard extends StatefulWidget {
  const QuickCreateNewBoard({Key? key}) : super(key: key);

  @override
  State<QuickCreateNewBoard> createState() => _QuickCreateNewBoardState();
}

class _QuickCreateNewBoardState extends State<QuickCreateNewBoard> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final _storyApi = StoryApi();

  late AppLocalizations _i18n;
  late TextEditingController _aboutController;
  late ProgressDialog _pr;
  late TextStyle styleLabel;
  late TextStyle styleBody;
  final _appHelper = AppHelper();

  @override
  void initState() {
    super.initState();
    _aboutController = TextEditingController();
    _pr = ProgressDialog(context, isDismissible: false);
  }

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = AppLocalizations.of(context);
    styleLabel = Theme.of(context).textTheme.labelMedium!;
    styleBody = Theme.of(context).textTheme.bodyMedium!;
  }

  @override
  Widget build(BuildContext context) {
    final styleLabel = Theme.of(context).textTheme.labelMedium;
    final styleBody = Theme.of(context).textTheme.bodyMedium;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leadingWidth: 50,
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
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              style: styleBody,
              controller: _aboutController,
              maxLength: 300,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: _i18n.translate("creative_mix_quick_hint"),
                hintStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              validator: (reason) => reason?.isEmpty ?? false
                  ? _i18n.translate("creative_mix_quick_hint")
                  : null,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: _updateChanges,
                child: Text(_i18n.translate("creative_mix_create")),
              ),
            ),
            const SizedBox(height: 80),
            GestureDetector(
              onTap: _appHelper.openTermsPage,
              child: Text(
                _i18n.translate("bot_test_warning"),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _updateChanges() async {
    _pr.show(_i18n.translate("thinking"));

    try {
      Storyboard storyboard = await _storyApi.quickStory(_aboutController.text);
      _aboutController.clear();

      Story story = storyboard.story![0];
      storyboardController.addNewStoryboard(storyboard);
      storyboardController.setCurrentBoard(storyboard);
      storyboardController.setCurrentStory(story);
      await Future.delayed(const Duration(seconds: 1));
      _pr.hide();
      if (mounted && context.mounted) {
        Navigator.pop(context);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryPageView(story: story),
          ),
        );
      }
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
