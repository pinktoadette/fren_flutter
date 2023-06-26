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
  _ConfirmPublishDetailsState createState() => _ConfirmPublishDetailsState();
}

class _ConfirmPublishDetailsState extends State<ConfirmPublishDetails> {
  late AppLocalizations _i18n;
  final _storyApi = StoryApi();
  Story? story;
  final _titleController = TextEditingController();
  final _aboutController = TextEditingController();
  final _selectedCategory = TextEditingController();

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
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    TextStyle? styleLabel = Theme.of(context).textTheme.labelMedium;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            _i18n.translate("publish_confirm_title"),
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
              Text(_i18n.translate("story_collection_title"),
                  style: styleLabel),
              TextFormField(
                controller: _titleController,
                maxLength: 80,
                decoration: InputDecoration(
                    hintText: _i18n.translate("story_collection_title"),
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                    floatingLabelBehavior: FloatingLabelBehavior.always),
                validator: (reason) {
                  if (reason?.isEmpty ?? false) {
                    return _i18n.translate("story_enter_title");
                  }
                  return null;
                },
              ),
              Text(_i18n.translate("publish_confirm_summary"),
                  style: styleLabel),
              TextFormField(
                controller: _aboutController,
                maxLength: 80,
                maxLines: 10,
                decoration: InputDecoration(
                    hintText: _i18n.translate("publish_confirm_summary"),
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                    floatingLabelBehavior: FloatingLabelBehavior.always),
                validator: (reason) {
                  if (reason?.isEmpty ?? false) {
                    return _i18n.translate("story_enter_title");
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_i18n.translate("publish_confirm_format"),
                      style: styleLabel),
                  Text(story!.layout?.name ?? Layout.CONVO.name),
                ],
              ),
              CategoryDropdownWidget(
                notifyParent: (value) {},
                selectedCategory: _selectedCategory.text,
              ),
              const SizedBox(
                height: 50,
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                      onPressed: () {
                        _updateChanges();
                      },
                      child: Text(_i18n.translate("publish"))))
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
    } catch (e) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
    }
  }
}
