import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
  State<AddNewStory> createState() => _AddNewStoryState();
}

class _AddNewStoryState extends State<AddNewStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final _storyApi = StoryApi();
  final _titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  File? _uploadPath;
  String? photoUrl;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leadingWidth: 20,
          centerTitle: false,
          title: Text(
            _i18n.translate("create_mix_new_collection"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton.icon(
                icon: isLoading == true
                    ? loadingButton(size: 16)
                    : const SizedBox.shrink(),
                onPressed: () {
                  _addNewStory();
                },
                label: Text(
                  _i18n.translate("add"),
                  style: Theme.of(context).textTheme.bodyMedium,
                ))
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                maxLength: 80,
                style: const TextStyle(fontSize: 16),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                    hintText: _i18n.translate("creative_mix_title"),
                    floatingLabelBehavior: FloatingLabelBehavior.always),
                validator: (reason) {
                  if (reason?.isEmpty ?? false) {
                    return _i18n.translate("creative_mix_enter_title");
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                child: Stack(
                  children: [
                    StoryCover(
                      width: width * 0.9,
                      height: width * 0.9,
                      photoUrl: '',
                      file: _uploadPath,
                      title: "Cover",
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
      String imageUrl = photoUrl ?? "";
      if (_uploadPath != null) {
        imageUrl = await uploadFile(
            file: _uploadPath!,
            category: UPLOAD_PATH_COLLECTION,
            categoryId: storyboardController.currentStoryboard.storyboardId);
      }
      await _storyApi.createStory(
          storyboardId: storyboardController.currentStoryboard.storyboardId,
          title: title,
          photoUrl: imageUrl);

      Get.snackbar(
          _i18n.translate("posted"), _i18n.translate("creative_mix_added"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS,
          colorText: Colors.black);
      Get.back(result: true);
    } catch (err, s) {
      debugPrint(err.toString());
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );

      await FirebaseCrashlytics.instance
          .recordError(err, s, reason: 'Cannot aadd a new story', fatal: true);
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
}
