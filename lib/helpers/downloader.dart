import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';

Future<String> saveImageFromUrl(String imageUrl) async {
  PermissionStatus status =
      await Permission.photos.status; // Use photos permission for iOS

  if (status.isDenied) {
    // Request permission if not granted previously
    status = await Permission.photos.request();
  }

  if (status.isGranted) {
    var response = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));

    if (response.statusCode == 200) {
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 80,
        name: "machi_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess']) {
        return "Saved";
      } else {
        throw "Failed to save";
      }
    }
    throw "Failed to fetch image";
  } else {
    // You can also guide the user to enable the permission in the app settings
    throw "Need to enable permission to access photos.";
  }
}
