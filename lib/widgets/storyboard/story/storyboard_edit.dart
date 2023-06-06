import 'dart:io';

import 'package:get/get.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:machi_app/widgets/story_cover.dart';

/// Edit and delete storyboard, including title and images
/// Swipe to delete individual stories
class StoryboardEdit extends StatefulWidget {
  const StoryboardEdit({Key? key}) : super(key: key);
  @override
  _StoryboardEditState createState() => _StoryboardEditState();
}

class _StoryboardEditState extends State<StoryboardEdit> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  late Storyboard storyboard;
  final _storyboardApi = StoryboardApi();
  File? _uploadPath;
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  storyboard.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  child: Stack(
                    children: [
                      StoryCover(
                        width: size.width * 0.75,
                        height: size.width * 0.75,
                        photoUrl: storyboard.photoUrl ?? "",
                        file: _uploadPath,
                        title: storyboard.title,
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
                const SizedBox(
                  height: 80,
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
                      _saveStoryboard();
                    },
                    label: Text(_i18n.translate("SAVE")))
              ],
            )
          ])),
    );
  }

  void _saveStoryboard() async {
    setState(() {
      isLoading = true;
    });
    String photoUrl = '';
    try {
      if (_uploadPath != null) {
        photoUrl = await uploadFile(
          file: _uploadPath!,
          category: UPLOAD_PATH_BOARD,
          categoryId: storyboard.storyboardId,
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

      await _storyboardApi.updateStoryboard(
          storyboardId: storyboard.storyboardId,
          title: _titleController.text,
          photoUrl: photoUrl);
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

  void _deleteMessage() {}
}
