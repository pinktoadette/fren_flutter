import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';

extension TextAlignExtension on TextAlign {
  static TextAlign fromString(String value) {
    switch (value) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'center':
        return TextAlign.center;
      // Add more cases for other enum values
      default:
        throw ArgumentError('Invalid TextAlign value: $value');
    }
  }
}

class AddEditTextCharacter {
  String text;
  Uint8List? imageBytes;
  File? attachmentPreview;
  String? galleryUrl;
  TextAlign? textAlign;
  String characterId;
  String characterName;

  AddEditTextCharacter({
    required this.text,
    this.imageBytes,
    this.attachmentPreview,
    this.galleryUrl,
    this.textAlign,
    required this.characterId,
    required this.characterName,
  });

  factory AddEditTextCharacter.fromJson(Map<String, dynamic> json) {
    debugPrint(json.toString());
    return AddEditTextCharacter(
      text: json['text'],
      imageBytes: json['imageBytes'] != null
          ? Uint8List.fromList(json['imageBytes'].cast<int>())
          : null,
      attachmentPreview: json['attachmentPreview'] != null
          ? File(json['attachmentPreview'])
          : null,
      galleryUrl: json['galleryUrl'],
      textAlign: json['textAlign'] != null
          ? TextAlignExtension.fromString(json['textAlign']) // Custom method
          : null,
      characterId: json['characterId'],
      characterName: json['characterName'],
    );
  }
}
