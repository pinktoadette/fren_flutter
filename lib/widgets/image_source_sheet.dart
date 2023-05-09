import 'dart:io';

import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {
  // Constructor
  ImageSourceSheet({Key? key, required this.onImageSelected, this.includeFile})
      : super(key: key);

  // Callback function to return image file
  final Function(File?) onImageSelected;
  // ImagePicker instance
  final picker = ImagePicker();

  bool? includeFile;
  bool? useAIGenerator;

  Future<void> selectedImage(BuildContext context, File? image) async {
    // init i18n
    final i18n = AppLocalizations.of(context);

    // Check file
    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          maxWidth: 400,
          maxHeight: 400,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: i18n.translate("edit_crop_image"),
                toolbarColor: Theme.of(context).primaryColor,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: i18n.translate("edit_crop_image"),
            ),
          ]);
      // Hold the file
      File? imageFile;
      // Check
      if (croppedFile != null) {
        imageFile = File(croppedFile.path);
      }
      // Callback
      onImageSelected(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Variables
    final i18n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        border: Border.all(width: 1.0, color: const Color(0xff707070)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  includeFile == true
                      ? i18n.translate("document")
                      : i18n.translate('photo'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.image, color: Colors.grey))
            ],
          ),

          const Divider(height: 5, thickness: 1),

          /// Select image from gallery
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: TextButton.icon(
              icon: const Icon(Iconsax.gallery, color: Colors.grey, size: 27),
              label: Text(i18n.translate("gallery"),
                  style: const TextStyle(fontSize: 16)),
              onPressed: () async {
                // Get image from device gallery
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile == null) return;
                selectedImage(context, File(pickedFile.path));
              },
            ),
          ),

          /// Capture image from camera
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: TextButton.icon(
              icon: const Icon(Iconsax.camera, color: Colors.grey),
              label: Text(i18n.translate("camera"),
                  style: const TextStyle(fontSize: 16)),
              onPressed: () async {
                // Capture image from camera
                final pickedFile = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (pickedFile == null) return;
                selectedImage(context, File(pickedFile.path));
              },
            ),
          ),

          // files for future
          if (includeFile == true)
            Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextButton.icon(
                  icon: const Icon(Iconsax.folder_open, color: Colors.grey),
                  label: Text(i18n.translate("file"),
                      style: const TextStyle(fontSize: 16)),
                  onPressed: null,
                )),
          if (useAIGenerator == true)
            Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextButton.icon(
                  icon: const Icon(Iconsax.pen_add, color: Colors.grey),
                  label: Text(i18n.translate("bot_generator"),
                      style: const TextStyle(fontSize: 16)),
                  onPressed: null,
                )),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
