import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:machi_app/datas/script.dart';

class TextUpdate {
  final String selection;
  final int indexStart;
  final int indexEnd;
  final Script original;
  final int pageNum;

  TextUpdate(
      {required this.selection,
      required this.indexStart,
      required this.indexEnd,
      required this.original,
      required this.pageNum});

  TextUpdate copyWith({
    String? selection,
    int? indexStart,
    int? indexEnd,
    Script? original,
    int? pageNum,
  }) {
    return TextUpdate(
      selection: selection ?? this.selection,
      indexStart: indexStart ?? this.indexStart,
      indexEnd: indexEnd ?? this.indexEnd,
      original: original ?? this.original,
      pageNum: pageNum ?? this.pageNum,
    );
  }
}

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
  String? text;
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
          ? TextAlignExtension.fromString(json['textAlign']) // Custom method
          : null,
      characterId: json['characterId'],
      characterName: json['characterName'],
    );
  }
}
