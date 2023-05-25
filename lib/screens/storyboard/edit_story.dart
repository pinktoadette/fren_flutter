import 'dart:io';

import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:get/get.dart';

class EditStory extends StatefulWidget {
  const EditStory({Key? key}) : super(key: key);

  @override
  _EditStoryState createState() => _EditStoryState();
}

class _EditStoryState extends State<EditStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  File? _uploadPath;
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
        children: [
          Text(
            storyboardController.currentStory.title,
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
                  photoUrl: storyboardController.currentStory.photoUrl ?? "",
                  file: _uploadPath,
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
          ),
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
                ElevatedButton(
                    onPressed: () async {},
                    child: Text(
                      _i18n.translate("SAVE"),
                      style: const TextStyle(fontSize: 14),
                    )),
              ],
            )
          ])),
    );
  }
}
