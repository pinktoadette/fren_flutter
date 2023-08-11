import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';

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
          ? TextAlign.values[json['textAlign']]
          : null,
      characterId: json['characterId'],
      characterName: json['characterName'],
    );
  }
}
