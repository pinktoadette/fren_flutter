import 'dart:io';

import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/profile/user_gallery.dart';

class ImageSourceSheet extends StatefulWidget {
  // Callback function to return image file
  final Function(File?) onImageSelected;

  /// Callback to return url image
  final Function(String) onGallerySelected;

  // ImagePicker instance
  final picker = ImagePicker();

  final bool? includeFile;

  ImageSourceSheet({
    Key? key,
    required this.onImageSelected,
    required this.onGallerySelected,
    this.includeFile,
  }) : super(key: key);

  @override
  State<ImageSourceSheet> createState() => _ImageSourceSheetState();
}

class _ImageSourceSheetState extends State<ImageSourceSheet> {
  late AppLocalizations _i18n;
  late Size size;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
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
                  widget.includeFile == true
                      ? _i18n.translate("document")
                      : _i18n.translate('photo'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.image))
            ],
          ),

          const Divider(height: 5, thickness: 1),

          /// Select image from gallery
          SizedBox(
              width: double.infinity,
              child: InkWell(
                  onTap: () async {
                    // Get image from device gallery
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile == null) return;
                    selectedImage(File(pickedFile.path));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        const Icon(Iconsax.gallery),
                        Text(" ${_i18n.translate("gallery")}",
                            style: const TextStyle(fontSize: 16))
                      ],
                    ),
                  ))),

          /// Capture image from camera
          SizedBox(
              width: double.infinity,
              child: InkWell(
                  onTap: () async {
                    // Capture image from camera
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile == null) return;
                    selectedImage(File(pickedFile.path));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        const Icon(Iconsax.camera),
                        Text(" ${_i18n.translate("camera")}",
                            style: const TextStyle(fontSize: 16))
                      ],
                    ),
                  ))),

          SizedBox(
              width: double.infinity,
              child: InkWell(
                  onTap: () async {
                    _showGallery(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        const Icon(Iconsax.gallery_export),
                        Text(" ${_i18n.translate("gallery_machi")}",
                            style: const TextStyle(fontSize: 16))
                      ],
                    ),
                  ))),
          // files for future
          if (widget.includeFile == true)
            Container(
                alignment: Alignment.topLeft,
                width: size.width,
                padding: const EdgeInsets.only(left: 10.0),
                child: TextButton.icon(
                  icon: const Icon(Iconsax.folder_open),
                  label: Text(_i18n.translate("file")),
                  onPressed: null,
                )),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showGallery(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: MODAL_HEIGHT_LARGE_FACTOR,
            child: UserGallery(
              userId: UserModel().user.userId,
              onFileTap: (val) {
                widget.onGallerySelected(val);
              },
            ));
      },
    );
  }

  Future<void> selectedImage(File? image) async {
    // init i18n

    // Check file
    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          maxWidth: 512,
          maxHeight: 512,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: _i18n.translate("edit_crop_image"),
                toolbarColor: Colors.black,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: _i18n.translate("edit_crop_image"),
            ),
          ]);
      // Hold the file
      File? imageFile;
      // Check
      if (croppedFile != null) {
        imageFile = File(croppedFile.path);
      }
      // Callback
      widget.onImageSelected(imageFile);
    }
  }
}
