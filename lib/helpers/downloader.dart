import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:machi_app/helpers/create_uuid.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String> saveImageFromUrl(String imageUrl) async {
  PermissionStatus status = await Permission.accessMediaLocation.status;

  if (status.isDenied) {
    // Request permission if not granted previously
    status = await Permission.accessMediaLocation.request();
  }

  if (status.isGranted) {
    var response = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));

    if (response.statusCode == 200) {
      await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
          quality: 60, name: "machi ${createUUID()}");
      return "Saved";
    }
    throw "Failed to save";
  } else {
    await openAppSettings();
  }
  throw "Need to enable permission to access media location.";
}
