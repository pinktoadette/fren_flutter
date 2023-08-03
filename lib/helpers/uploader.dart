import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// Specify file, path and filename
/// Images using their respective ids will be overwriting those
Future<String> uploadFile({
  required File file,
  required String category, // board | room | user | bot
  required String categoryId, // respective Id
}) async {
  final _storageRef = FirebaseStorage.instance;

  // Upload file
  final UploadTask uploadTask =
      _storageRef.ref().child(category + '/' + categoryId).putFile(file);
  final TaskSnapshot snapshot = await uploadTask;
  String url = await snapshot.ref.getDownloadURL();
  // return file link
  return url;
}

Future<String> uploadBytesFile({
  required Uint8List uint8arr, // Change the parameter type
  required String category, // board | room | user | bot
  required String categoryId, // respective Id
}) async {
  final _storageRef = FirebaseStorage.instance;

  // Upload file
  final UploadTask uploadTask = _storageRef
      .ref()
      .child(category + '/' + categoryId)
      .putData(uint8arr); // Convert Uint8List to List<int> before uploading
  final TaskSnapshot snapshot = await uploadTask;
  String url = await snapshot.ref.getDownloadURL();
  // Return file link
  return url;
}
