import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:machi_app/helpers/create_uuid.dart';

/// Specify file, path and filename
/// Images using their respective ids will be overwriting those
Future<String> uploadFile({
  required File file,
  required String category, // board | room | user | bot
  required String categoryId, // respective Id
}) async {
  final storageRef = FirebaseStorage.instance;

  // Upload file
  final UploadTask uploadTask =
      storageRef.ref().child('$category/$categoryId').putFile(file);
  final TaskSnapshot snapshot = await uploadTask;
  String url = await snapshot.ref.getDownloadURL();
  // return file link
  return url;
}

/// upload using URL
Future<String> uploadUrl({
  required String url,
  required String category, // board | room | user | bot
  required String categoryId, // respective Id
}) async {
  final storageRef = FirebaseStorage.instance;

  // Get the image extension from the URL using regular expressions
  RegExp regExp = RegExp(r'\.([a-zA-Z0-9]+)$');
  Match? match = regExp.firstMatch(url);
  String extension = match?.group(1) ?? 'jpg'; // Extension

  // Download the file from the provided URL
  final http.Response response = await http.get(Uri.parse(url));
  final Uint8List bytes = response.bodyBytes;

  // Upload file with the appropriate extension
  final UploadTask uploadTask = storageRef
      .ref()
      .child('$category/$categoryId.$extension')
      .putData(bytes, SettableMetadata(contentType: 'image/$extension'));
  final TaskSnapshot snapshot = await uploadTask;
  String uploadedUrl = await snapshot.ref.getDownloadURL();

  // Return the uploaded file link
  return uploadedUrl;
}

Future<String> uploadBytesFile({
  required Uint8List uint8arr, // Change the parameter type
  required String category, // board | room | user | bot
  required String categoryId, // respective Id
}) async {
  final storageRef = FirebaseStorage.instance;

  // Upload file
  final UploadTask uploadTask = storageRef
      .ref()
      .child('$category/$categoryId')
      .putData(uint8arr); // Convert Uint8List to List<int> before uploading
  final TaskSnapshot snapshot = await uploadTask;
  String url = await snapshot.ref.getDownloadURL();
  // Return file link
  return url;
}

Future<String> copyFileToDifferentFolder({
  required String sourceUrl,
  required String destinationCategory,
  String contentType = 'image/png',
}) async {
  try {
    final storageRef = FirebaseStorage.instance;

    // Get the file name from the source URL
    final List<String> urlSegments = Uri.parse(sourceUrl).pathSegments;
    final String fileName = urlSegments.last;

    // Download the file from the source URL
    final http.Response response = await http.get(Uri.parse(sourceUrl));
    final Uint8List fileBytes = Uint8List.fromList(response.bodyBytes);

    // Upload the file to the destination folder
    final destinationFolderRef = storageRef.ref().child(destinationCategory);
    final destinationFileRef = destinationFolderRef.child(fileName);

    final TaskSnapshot uploadTask = await destinationFileRef.putData(
      fileBytes,
      SettableMetadata(contentType: contentType), // Set the content type
    );
    final String newUrl = await uploadTask.ref.getDownloadURL();

    debugPrint('File copied successfully.');

    return newUrl;
  } catch (err) {
    rethrow;
  }
}
