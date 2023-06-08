import 'package:machi_app/constants/constants.dart';

class Gallery {
  final String photoUrl;
  final String caption;
  final int createdAt;
  final int updatedAt;

  Gallery(
      {required this.photoUrl,
      required this.caption,
      required this.createdAt,
      required this.updatedAt});

  Gallery copyWith({String? photoUrl, String? caption}) {
    return Gallery(
        photoUrl: photoUrl ?? this.photoUrl,
        caption: caption ?? this.caption,
        createdAt: createdAt,
        updatedAt: updatedAt);
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      GALLERY_IMAGE_CAPTION: caption,
      GALLERY_IMAGE_URL: photoUrl,
      CREATED_AT: createdAt,
      UPDATED_AT: updatedAt
    };
  }

  factory Gallery.fromJson(Map<String, dynamic> doc) {
    return Gallery(
        caption: doc[GALLERY_IMAGE_CAPTION],
        photoUrl: doc[GALLERY_IMAGE_URL],
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt());
  }
}
