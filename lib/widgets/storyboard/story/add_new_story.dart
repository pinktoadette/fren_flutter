import 'dart:io';

import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:get/get.dart';

class AddNewStory extends StatefulWidget {
  const AddNewStory({Key? key}) : super(key: key);

  @override
  _AddNewStoryState createState() => _AddNewStoryState();
}

class _AddNewStoryState extends State<AddNewStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final _storyApi = StoryApi();

  final _titleController = TextEditingController();
  File? _uploadPath;
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(_i18n.translate("new_story_collection")),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                _i18n.translate("story_collection_create"),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                child: Stack(
                  children: [
                    StoryCover(
                      width: width * 0.8,
                      height: width * 0.8,
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
                buildCounter: (_,
                        {required currentLength,
                        maxLength,
                        required isFocused}) =>
                    _counter(context, currentLength, maxLength),
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
            ],
          ),
        ));
  }

  void _addNewStory() async {
    String title = _titleController.text;
    setState(() {
      isLoading = true;
    });
    try {
      String photoUrl = '';
      if (_uploadPath != null) {
        photoUrl = await uploadFile(
            file: _uploadPath!,
            category: UPLOAD_PATH_COLLECTION,
            categoryId:
                "${storyboardController.currentStoryboard.storyboardId}_$title");
      }
      await _storyApi.createStory(
          storyboardId: storyboardController.currentStoryboard.storyboardId,
          title: title,
          photoUrl: photoUrl);

      Get.snackbar(
        _i18n.translate("posted"),
        _i18n.translate("story_added"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_SUCCESS,
      );
      Navigator.of(context).pop();
    } catch (err) {
      debugPrint(err.toString());
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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

  Widget _counter(BuildContext context, int currentLength, int? maxLength) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: Container(
          alignment: Alignment.topLeft,
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentLength.toString() + "/" + maxLength.toString(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const Spacer(),
                ElevatedButton.icon(
                    icon: isLoading == true
                        ? loadingButton(size: 16)
                        : const SizedBox.shrink(),
                    onPressed: () {
                      _addNewStory();
                    },
                    label: Text(_i18n.translate("add")))
              ],
            )
          ])),
    );
  }
}
