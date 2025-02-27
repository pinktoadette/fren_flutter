import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/dialogs/progress_dialog.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/forms/category_dropdown.dart';

class ManaulCreateNewBoard extends StatefulWidget {
  const ManaulCreateNewBoard({Key? key}) : super(key: key);

  @override
  State<ManaulCreateNewBoard> createState() => _ManaulCreateNewBoardState();
}

class _ManaulCreateNewBoardState extends State<ManaulCreateNewBoard> {
  late AppLocalizations _i18n;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final _storyboardApi = StoryboardApi();
  TextEditingController _selectedCategory = TextEditingController();
  late TextStyle styleLabel;
  late TextStyle styleBody;
  late ProgressDialog _pr;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedCategory.text = 'General';
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
    styleLabel = Theme.of(context).textTheme.labelMedium!;
    styleBody = Theme.of(context).textTheme.bodyMedium!;
    _pr = ProgressDialog(context, isDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leadingWidth: 50,
          centerTitle: false,
          title: Text(
            _i18n.translate("creative_mix_manual"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              CategoryDropdownWidget(
                notifyParent: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                selectedCategory: _selectedCategory.text,
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
    _pr.show(_i18n.translate("creating"));

    try {
      await _storyboardApi.createStoryboard(
          text: _aboutController.text,
          title: _titleController.text,
          image: '',
          summary: _aboutController.text,
          category: _selectedCategory.text,
          character: UserModel().user.username,
          characterId: UserModel().user.userId);
      int count = 0;
      Get.until((route) => count++ >= 2);
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Error creating manual board', fatal: true);
    } finally {
      _pr.hide();
    }
  }
}
