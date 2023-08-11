import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:machi_app/widgets/story_cover.dart';

/// Edit and delete storyboard, including title and images
/// Swipe to delete individual stories
class StoryboardEdit extends StatefulWidget {
  const StoryboardEdit({Key? key}) : super(key: key);
  @override
  State<StoryboardEdit> createState() => _StoryboardEditState();
}

class _StoryboardEditState extends State<StoryboardEdit> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  late Storyboard storyboard;
  final _storyboardApi = StoryboardApi();
  File? _uploadPath;
  String? photoUrl;
  final _titleController = TextEditingController();
  bool isLoading = false;
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
    setState(() {
      storyboard = storyboardController.currentStoryboard;
      _titleController.text = storyboard.title;
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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text(_i18n.translate("SAVE")),
                onPressed: () {
                  _saveStoryboard();
                },
              )),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  maxLength: 80,
                  decoration: InputDecoration(
                      hintText: _i18n.translate("story_collection_title"),
                      floatingLabelBehavior: FloatingLabelBehavior.always),
                  validator: (reason) {
                    if (reason?.isEmpty ?? false) {
                      return _i18n.translate("story_enter_title");
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  child: Stack(
                    children: [
                      StoryCover(
                        width: size.width * 0.9,
                        height: size.width * 0.9,
                        photoUrl: photoUrl ?? storyboard.photoUrl ?? "",
                        file: _uploadPath,
                        title: storyboard.title,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
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
              ],
            ),
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
                // Navigator.of(context).pop();
              },
            ));
  }

  void _saveStoryboard() async {
    setState(() {
      isLoading = true;
    });
    String imageUrl = photoUrl ?? "";
    try {
      if (_uploadPath != null) {
        imageUrl = await uploadFile(
          file: _uploadPath!,
          category: UPLOAD_PATH_BOARD,
          categoryId: storyboard.storyboardId,
        );
      }

      if (_titleController.text.isEmpty) {
        Get.snackbar(
          _i18n.translate("error"),
          _i18n.translate("validation_1_character"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_ERROR,
        );
        return;
      }

      await _storyboardApi.updateStoryboard(
          storyboardId: storyboard.storyboardId,
          title: _titleController.text,
          photoUrl: imageUrl);
      Get.snackbar(
          _i18n.translate("success"), _i18n.translate("update_successful"),
          snackPosition: SnackPosition.TOP, backgroundColor: APP_SUCCESS);
    } catch (err, s) {
      debugPrint(err.toString());
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance
          .recordError(err, s, reason: 'Cannot save storyboard', fatal: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
