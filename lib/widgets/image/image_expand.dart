import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/gallery.dart';
import 'package:machi_app/helpers/downloader.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/widgets/common/avatar_initials.dart';

class ExpandedImagePage extends StatelessWidget {
  final Gallery gallery;

  const ExpandedImagePage({super.key, required this.gallery});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black, // Set background color
      body: Stack(
        children: [
          GestureDetector(
            // Dismiss the page when tapped
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.5,
                    child: Hero(
                      tag: gallery.photoUrl,
                      child: Image(image: ImageCacheWrapper(gallery.photoUrl)),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.5 - 110,
                    child: SingleChildScrollView(
                      child: Text("Prompt: ${gallery.caption}"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
              bottom: 30,
              left: 0,
              child: Container(
                  color: Colors.black.withOpacity(0.8),
                  width: size.width,
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (gallery.createdBy != null)
                        Row(
                          children: [
                            AvatarInitials(
                                radius: 16,
                                userId: gallery.createdBy!.userId,
                                photoUrl: gallery.createdBy!.photoUrl,
                                username: gallery.createdBy!.username),
                          ],
                        ),
                      TextButton(
                        onPressed: () async {
                          try {
                            await saveImageFromUrl(gallery.photoUrl);
                          } catch (err, stack) {
                            Get.snackbar(
                              "Error",
                              "Unable to download",
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: APP_ERROR,
                            );
                            await FirebaseCrashlytics.instance.recordError(
                                err, stack,
                                reason:
                                    'Unable to download from image expander ${err.toString()}',
                                fatal: false);
                          }
                        },
                        child: const Icon(Iconsax.document_download),
                      ),
                    ],
                  ))),
        ],
      ),
    );
  }
}
