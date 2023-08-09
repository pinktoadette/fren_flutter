import 'package:machi_app/constants/constants.dart';

class GalleryUser {
  final String userId;
  final String photoUrl;
  final String username;

  GalleryUser(
      {required this.userId, required this.photoUrl, required this.username});

  factory GalleryUser.fromJson(Map<String, dynamic> doc) {
    return GalleryUser(
        userId: doc[USER_ID],
        photoUrl: doc[USER_PROFILE_PHOTO],
        username: doc[USER_USERNAME]);
  }
}

class Gallery {
  final String photoUrl;
  final String caption;
  final GalleryUser? createdBy;
  final int createdAt;
  final int updatedAt;

  Gallery(
      {required this.photoUrl,
      required this.caption,
      required this.createdAt,
      required this.updatedAt,
      this.createdBy});

  Gallery copyWith({String? photoUrl, String? caption}) {
    return Gallery(
        photoUrl: photoUrl ?? this.photoUrl,
        caption: caption ?? this.caption,
        createdAt: createdAt,
        updatedAt: updatedAt,
        createdBy: createdBy);
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      GALLERY_IMAGE_CAPTION: caption,
      GALLERY_IMAGE_URL: photoUrl,
      CREATED_AT: createdAt,
      UPDATED_AT: updatedAt,
      GALLERY_CREATED_BY: createdBy
    };
  }

  factory Gallery.fromJson(Map<String, dynamic> doc) {
    GalleryUser user = GalleryUser.fromJson(doc[GALLERY_CREATED_BY]);
    return Gallery(
        caption: doc[GALLERY_IMAGE_CAPTION],
        photoUrl: doc[GALLERY_IMAGE_URL],
        createdAt: doc[CREATED_AT].toInt(),
        updatedAt: doc[UPDATED_AT].toInt(),
        createdBy: user);
  }
}
