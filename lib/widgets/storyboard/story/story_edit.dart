import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/forms/category_dropdown.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:machi_app/widgets/story_cover.dart';

class StoryEdit extends StatefulWidget {
  const StoryEdit({Key? key, required this.onUpdateStory}) : super(key: key);
  final Function(Story story) onUpdateStory;

  @override
  State<StoryEdit> createState() => _StoryEditState();
}

class _StoryEditState extends State<StoryEdit> {
  final StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final _storyApi = StoryApi();
  final _titleController = TextEditingController();

  File? _uploadPath;
  String? _selectedCategory;
  String? photoUrl;

  bool isLoading = false;
  late Size size;
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
    setState(() {
      _titleController.text = storyboardController.currentStory.title;
      _selectedCategory = storyboardController.currentStory.category;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
    size = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
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
          Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                  icon: isLoading == true
                      ? loadingButton(size: 16, color: Colors.black)
                      : const SizedBox.shrink(),
                  onPressed: () {
                    _saveStory();
                  },
                  label: Text(_i18n.translate("SAVE")))),
          Text(_i18n.translate("creative_mix_title"),
              style: Theme.of(context).textTheme.labelMedium),
          TextFormField(
            controller: _titleController,
            maxLength: 80,
            buildCounter: (_,
                    {required currentLength, maxLength, required isFocused}) =>
                _counter(context, currentLength, maxLength),
            decoration: InputDecoration(
                hintText: _i18n.translate("creative_mix_title"),
                hintStyle:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                floatingLabelBehavior: FloatingLabelBehavior.always),
            validator: (reason) {
              if (reason?.isEmpty ?? false) {
                return _i18n.translate("creative_mix_enter_title");
              }
              return null;
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
          const SizedBox(
            height: 20,
          ),
          CategoryDropdownWidget(
            notifyParent: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            selectedCategory: _selectedCategory,
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
                    photoUrl: photoUrl ?? "",
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
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context).colorScheme.background,
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
          )),
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
                  "$currentLength/$maxLength",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const Spacer(),
              ],
            )
          ])),
    );
  }

  void _saveStory() async {
    setState(() {
      isLoading = true;
    });
    String imageUrl =
        photoUrl ?? storyboardController.currentStory.photoUrl ?? "";
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
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_ERROR,
        );
        return;
      }

      await _storyApi.updateStory(
          story: story,
          title: _titleController.text,
          photoUrl: imageUrl,
          category: _selectedCategory);
      Story s = story.copyWith(
          title: _titleController.text,
          photoUrl: imageUrl,
          category: _selectedCategory);
      widget.onUpdateStory(s);

      Get.snackbar(
          _i18n.translate("success"), _i18n.translate("update_successful"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS,
          colorText: Colors.black);
    } catch (err, s) {
      debugPrint(err.toString());
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance
          .recordError(err, s, reason: 'Cannot save story', fatal: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
