import 'dart:async';
import 'dart:io';

import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:get/get.dart';

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
  File? _uploadPath;
  bool isLoading = false;

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

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(_i18n.translate("add_story_collection")),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                child: Stack(
                  children: [
                    StoryCover(
                      width: 100,
                      height: 100,
                      photoUrl: '',
                      file: _uploadPath,
                      title: "Cover",
                    ),
                    Positioned(
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            Theme.of(context).colorScheme.background,
                        child: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.primary,
                          size: 12,
                        ),
                      ),
                      right: 0,
                      bottom: 0,
                    ),
                  ],
                ),
                onTap: () async {
                  /// Update story image
                  _selectImage(path: 'collection');
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _titleController,
                maxLength: 80,
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
                maxLength: 80,
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
                maxLength: 250,
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
    setState(() {
      isLoading = true;
    });
    _validateFields();
    try {
      String photoUrl = await uploadFile(
          file: _uploadPath!,
          category: 'collection',
          categoryId: "${widget.storyboard.storyboardId}_$title");
      await _storyApi.createStory(
          storyboardId: widget.storyboard.storyboardId,
          title: title,
          photoUrl: photoUrl,
          subtitle: subtitle,
          summary: summary);

      Get.snackbar(
        _i18n.translate("posted"),
        _i18n.translate("story_comment_sucess"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_SUCCESS,
      );
      Timer.periodic(const Duration(seconds: 2), (Timer t) async {
        Get.back();
      });
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

  void _validateFields() {}

  void _selectImage({required String path}) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) => ImageSourceSheet(
              onImageSelected: (image) async {
                if (image != null) {
                  setState(() {
                    _uploadPath = image;
                  });
                  Navigator.of(context).pop();
                }
              },
            ));
  }
}
