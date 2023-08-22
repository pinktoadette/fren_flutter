import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as imglib;
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<void> deleteFileByUrl(String fileUrl) async {
  try {
    Reference photoRef = FirebaseStorage.instance.refFromURL(fileUrl);
    await photoRef.delete();
  } catch (error, stack) {
    await FirebaseCrashlytics.instance.recordError(error, stack,
        reason:
            'Unable to delete file: ${error.toString()}. Image url: $fileUrl',
        fatal: false);
    rethrow;
  }
}

/// Images using their respective ids will be overwriting those
Future<String> uploadFile({
  required File file,
  required String category, // board | room | user | bot
  required String categoryId, // respective Id
}) async {
  try {
    final storageRef = FirebaseStorage.instance;

    // Upload file
    final UploadTask uploadTask =
        storageRef.ref().child('$category/$categoryId').putFile(file);
    final TaskSnapshot snapshot = await uploadTask;
    String url = await snapshot.ref.getDownloadURL();
    // return file link
    return url;
  } catch (error, stack) {
    await FirebaseCrashlytics.instance.recordError(error, stack,
        reason: 'Unable to upload using local File: ${error.toString()}.',
        fatal: false);
    rethrow;
  }
}

/// upload using URL
Future<Map<String, String>> uploadUrl({
  required String url,
  required String category, // collection | script | message | user | bot
  required String categoryId, // respective Id
}) async {
  try {
    final response = await http.get(Uri.parse(url));
    final Uint8List bytes = response.bodyBytes;

    // Create an image from the downloaded bytes
    imglib.Image image = imglib.decodeImage(bytes)!;

    // Compress and save the original image
    imglib.Image compressedImage = imglib.copyResize(image, width: 1024);
    final originalImageBytes = imglib.encodeJpg(compressedImage, quality: 70);

    // Create a thumbnail by cropping the center to 512x512
    imglib.Image thumbnail = cropCenter(image, 512, 512);
    final thumbnailBytes = imglib.encodeJpg(thumbnail, quality: 85);

    // Upload the original image
    final storageRef = FirebaseStorage.instance.ref();
    final originalImageRef =
        storageRef.child('$category/$categoryId/$categoryId.jpg');
    final originalTask = originalImageRef.putData(
      originalImageBytes,
      SettableMetadata(contentType: 'image/jpg'),
    );

    // Upload the thumbnail
    final thumbnailImageRef =
        storageRef.child('$category/$categoryId/thumbnail_$categoryId.jpg');
    final thumbnailTask = thumbnailImageRef.putData(
      thumbnailBytes,
      SettableMetadata(contentType: 'image/jpg'),
    );

    // Wait for both uploads to complete
    await Future.wait([
      originalTask.whenComplete(() => null),
      thumbnailTask.whenComplete(() => null)
    ]);

    // Get the URLs of both uploaded images
    final originalImageUrl = await originalImageRef.getDownloadURL();
    final thumbnailImageUrl = await thumbnailImageRef.getDownloadURL();

    // Return the URLs
    return {'original': originalImageUrl, 'thumbnail': thumbnailImageUrl};
  } catch (error, stack) {
    await FirebaseCrashlytics.instance.recordError(error, stack,
        reason:
            'Unable to upload from URL: ${error.toString()}. Image url: $url',
        fatal: false);
    rethrow;
  }
}

Future<String> uploadBytesFile({
  required Uint8List uint8arr, // Change the parameter type
  required String category, // board | room | user | bot
  required String categoryId, // respective Id
}) async {
  try {
    final storageRef = FirebaseStorage.instance;

    // Upload file
    final UploadTask uploadTask = storageRef
        .ref()
        .child('$category/$categoryId')
        .putData(uint8arr, SettableMetadata(contentType: 'image/png'));
    final TaskSnapshot snapshot = await uploadTask;
    String url = await snapshot.ref.getDownloadURL();
    // Return file link
    return url;
  } catch (error, stack) {
    await FirebaseCrashlytics.instance.recordError(error, stack,
        reason: 'Unable to load bytes in uploader: ${error.toString()}.',
        fatal: false);
    rethrow;
  }
}

Future<String> copyFileToDifferentFolder(
    {required String sourceUrl,
    required String destinationCategory,
    String contentType = 'image/jpg',
    String? customName}) async {
  try {
    final storageRef = FirebaseStorage.instance;

    // Get the file name from the source URL
    final List<String> urlSegments = Uri.parse(sourceUrl).pathSegments;
    final String fileName = customName ?? urlSegments.last;

    // Download the file from the source URL
    final http.Response response = await http.get(Uri.parse(sourceUrl));
    final Uint8List fileBytes = Uint8List.fromList(response.bodyBytes);

    final compressedBytes = await FlutterImageCompress.compressWithList(
      fileBytes,
      minHeight: 300,
      minWidth: 300,
    );

    // Upload the file to the destination folder
    final destinationFolderRef = storageRef.ref().child(destinationCategory);
    final destinationFileRef = destinationFolderRef.child(fileName);

    final TaskSnapshot uploadTask = await destinationFileRef.putData(
      compressedBytes,
      SettableMetadata(contentType: contentType), // Set the content type
    );
    final String newUrl = await uploadTask.ref.getDownloadURL();

    debugPrint('File copied successfully.');

    return newUrl;
  } catch (error, stack) {
    await FirebaseCrashlytics.instance.recordError(error, stack,
        reason:
            'Unable to copy file to another location: ${error.toString()}. Image url: $sourceUrl',
        fatal: false);
    rethrow;
  }
}

imglib.Image cropCenter(imglib.Image im, int newWidth, int newHeight) {
  final width = im.width;
  final height = im.height;
  final left = (width - newWidth) ~/ 2;
  final top = (height - newHeight) ~/ 2;
  final right = (width + newWidth) ~/ 2;
  final bottom = (height + newHeight) ~/ 2;
  return imglib.copyCrop(im,
      x: left, y: top, width: right - left, height: bottom - top);
}
