import 'package:dotted_border/dotted_border.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/no_data.dart';
import 'package:machi_app/widgets/storyboard/story/story_item_widget.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/storyboard/story/storyboard_header.dart';

class AddNewStory extends StatefulWidget {
  final Storyboard storyboard;
  const AddNewStory({Key? key, required this.storyboard}) : super(key: key);

  @override
  _AddNewStoryState createState() => _AddNewStoryState();
}

class _AddNewStoryState extends State<AddNewStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final _storyApi = StoryApi();

  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _summaryController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _summaryController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: Text(_i18n.translate("story_collection")),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_i18n.translate("add_story_collection")),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _subtitleController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: _i18n.translate("story_collection_subtitle"),
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                    floatingLabelBehavior: FloatingLabelBehavior.always),
                validator: (reason) {
                  if (reason?.isEmpty ?? false) {
                    return _i18n.translate("story_enter_subtitle");
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _summaryController,
                maxLines: 4,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: _i18n.translate("story_collection_summary"),
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                    floatingLabelBehavior: FloatingLabelBehavior.always),
                validator: (reason) {
                  if (reason?.isEmpty ?? false) {
                    return _i18n.translate("story_enter_subtitle");
                  }
                  return null;
                },
              ),
              Text(
                _i18n.translate("story_collection_summary_info"),
                style: const TextStyle(fontSize: 12),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Spacer(),
                  ElevatedButton(
                      onPressed: () {
                        _addNewStory();
                      },
                      child: Text(_i18n.translate("add")))
                ],
              )
            ],
          ),
        ));
  }

  void _addNewStory() async {
    String title = _titleController.text;
    String subtitle = _subtitleController.text;
    String summary = _summaryController.text;

    try {
      Story story = await _storyApi.createStory(
          storyboardId: widget.storyboard.storyboardId,
          title: title,
          subtitle: subtitle,
          summary: summary);
      Get.snackbar(
        _i18n.translate("posted"),
        _i18n.translate("story_comment_sucess"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_SUCCESS,
      );
    } catch (err) {
      debugPrint(err.toString());
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }
}
