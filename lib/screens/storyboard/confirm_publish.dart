import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/forms/category_dropdown.dart';
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';
import 'package:machi_app/widgets/storyboard/publish_story.dart';

class ConfirmPublishDetails extends StatefulWidget {
  final Story story;
  const ConfirmPublishDetails({Key? key, required this.story})
      : super(key: key);

  @override
  State<ConfirmPublishDetails> createState() => _ConfirmPublishDetailsState();
}

class _ConfirmPublishDetailsState extends State<ConfirmPublishDetails> {
  late AppLocalizations _i18n;
  final _storyApi = StoryApi();
  Story? story;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  TextEditingController _selectedCategory = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      story = widget.story;
      _titleController.text = widget.story.title;
      _aboutController.text = widget.story.summary ?? "";
      _selectedCategory.text = widget.story.category;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _aboutController.dispose();
    _selectedCategory.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    TextStyle? styleLabel = Theme.of(context).textTheme.labelMedium;
    TextStyle? styleBody = Theme.of(context).textTheme.bodyMedium;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: false,
          titleSpacing: 0,
          title: Text(
            _i18n.translate("publish_confirm"),
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
              Text(_i18n.translate("publish_confirm_summary"),
                  style: styleLabel),
              TextFormField(
                style: styleBody,
                controller: _aboutController,
                maxLength: 80,
                maxLines: 3,
                decoration: InputDecoration(
                    hintText: _i18n.translate("publish_confirm_summary"),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_i18n.translate("publish_confirm_format"),
                      style: styleLabel),
                  Text(story?.layout?.name ?? Layout.CONVO.name),
                ],
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
                      child: Text(_i18n.translate("publish")))),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ));
  }

  void _updateChanges() async {
    try {
      await _storyApi.updateStory(
        story: story!,
        title: _titleController.text,
        summary: _aboutController.text,
        category: _selectedCategory.text,
      );

      Get.to(() => PublishStory(story: story!));
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Error on publishing story', fatal: true);
    }
  }
}
