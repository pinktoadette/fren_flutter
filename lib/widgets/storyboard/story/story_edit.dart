import 'dart:io';

import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:get/get.dart';

class StoryEdit extends StatefulWidget {
  const StoryEdit({Key? key}) : super(key: key);

  @override
  _StoryEditState createState() => _StoryEditState();
}

class _StoryEditState extends State<StoryEdit> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final _storyApi = StoryApi();
  File? _uploadPath;
  String? photoUrl;

  final _titleController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _titleController.text = storyboardController.currentStory.title;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _i18n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            storyboardController.currentStory.title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.left,
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
              child: GestureDetector(
            child: Stack(
              children: [
                if (_uploadPath != null && photoUrl == null)
                  StoryCover(
                    width: size.width * 0.75,
                    height: size.width * 0.75,
                    photoUrl: "",
                    file: _uploadPath,
                    title: storyboardController.currentStory.title,
                  ),
                if (_uploadPath == null && photoUrl != null)
                  StoryCover(
                    width: size.width * 0.75,
                    height: size.width * 0.75,
                    photoUrl: photoUrl,
                    title: storyboardController.currentStory.title,
                  ),
                if (_uploadPath == null && photoUrl == null)
                  StoryCover(
                    width: size.width * 0.75,
                    height: size.width * 0.75,
                    photoUrl: storyboardController.currentStory.photoUrl ?? "",
                    title: storyboardController.currentStory.title,
                  ),
                Positioned(
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context).colorScheme.background,
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
          )),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: _titleController,
            maxLength: 80,
            buildCounter: (_,
                    {required currentLength, maxLength, required isFocused}) =>
                _counter(context, currentLength, maxLength),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: _i18n.translate("story_collection_title"),
                hintStyle:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                floatingLabelBehavior: FloatingLabelBehavior.always),
            validator: (reason) {
              if (reason?.isEmpty ?? false) {
                return _i18n.translate("story_enter_title");
              }
              return null;
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
        ],
      ),
    );
  }

  void _selectImage({required String path}) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) => ImageSourceSheet(
              onImageSelected: (image) async {
                if (image != null) {
                  setState(() {
                    _uploadPath = image;
                    photoUrl = null;
                  });
                  Navigator.of(context).pop();
                }
              },
              onGallerySelected: (imageUrl) async {
                setState(() {
                  photoUrl = imageUrl;
                  _uploadPath = null;
                });
                Navigator.of(context).pop();
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
                        ? loadingButton(size: 16, color: Colors.white)
                        : const SizedBox.shrink(),
                    onPressed: () {
                      _saveStory();
                    },
                    label: Text(_i18n.translate("SAVE")))
              ],
            )
          ])),
    );
  }

  void _saveStory() async {
    setState(() {
      isLoading = true;
    });
    String imageUrl = photoUrl ?? "";
    Story story = storyboardController.currentStory;
    try {
      if (_uploadPath != null) {
        imageUrl = await uploadFile(
          file: _uploadPath!,
          category: UPLOAD_PATH_COLLECTION,
          categoryId: story.storyId,
        );
      }

      if (_titleController.text.isEmpty) {
        Get.snackbar(
          _i18n.translate("error"),
          _i18n.translate("validation_1_character"),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: APP_ERROR,
        );
        return;
      }

      await _storyApi.updateStory(
          storyId: story.storyId,
          title: _titleController.text,
          photoUrl: imageUrl);
      Get.snackbar(
        _i18n.translate("success"),
        _i18n.translate("update_successful"),
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
