import 'dart:io';
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
