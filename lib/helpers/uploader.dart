import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadFile(
    {required File file,
    required String category, // chatroom | user | bot
    required String categoryId // respective Id
    }) async {
  final _storageRef = FirebaseStorage.instance;

  // Image name
  String imageName =
      categoryId + DateTime.now().millisecondsSinceEpoch.toString();

  // Upload file
  final UploadTask uploadTask =
      _storageRef.ref().child(category + '/' + imageName).putFile(file);
  final TaskSnapshot snapshot = await uploadTask;
  String url = await snapshot.ref.getDownloadURL();
  // return file link
  return url;
}
