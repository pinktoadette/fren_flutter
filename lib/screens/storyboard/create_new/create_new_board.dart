import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/create_uuid.dart';
import 'package:machi_app/models/user_model.dart';

class CreateNewBoard extends StatefulWidget {
  const CreateNewBoard({Key? key}) : super(key: key);

  @override
  State<CreateNewBoard> createState() => _CreateNewBoardState();
}

class _CreateNewBoardState extends State<CreateNewBoard> {
  late AppLocalizations _i18n;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  final _storyboardApi = StoryboardApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    TextStyle? styleLabel = Theme.of(context).textTheme.labelMedium;
    TextStyle? styleBody = Theme.of(context).textTheme.bodyMedium;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          titleSpacing: 0,
          centerTitle: false,
          title: Text(
            _i18n.translate("creative_mix_new_board"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(_i18n.translate("creative_mix_title"), style: styleLabel),
              TextFormField(
                style: styleBody,
                controller: _titleController,
                maxLength: 80,
                decoration: InputDecoration(
                    hintText: _i18n.translate("creative_mix_title"),
                    hintStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    floatingLabelBehavior: FloatingLabelBehavior.always),
                validator: (reason) {
                  if (reason?.isEmpty ?? false) {
                    return _i18n.translate("creative_mix_enter_title");
                  }
                  return null;
                },
              ),
              Text(_i18n.translate("creative_mix_description"),
                  style: styleLabel),
              TextFormField(
                style: styleBody,
                controller: _aboutController,
                maxLength: 120,
                decoration: InputDecoration(
                    hintText: _i18n.translate("creative_mix_description"),
                    hintStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    floatingLabelBehavior: FloatingLabelBehavior.always),
                validator: (reason) {
                  if (reason?.isEmpty ?? false) {
                    return _i18n.translate("creative_mix_enter_title");
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
                height: 50,
              ),
            ],
          ),
        ));
  }

  void _updateChanges() async {
    try {
      await _storyboardApi.createStoryboard(
          text: _aboutController.text,
          title: _titleController.text,
          image: '',
          summary: _aboutController.text,
          character: UserModel().user.username,
          characterId: UserModel().user.userId);
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Error creating manual board', fatal: true);
    }
  }
}
