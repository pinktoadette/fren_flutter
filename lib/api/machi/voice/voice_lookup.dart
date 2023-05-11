import 'package:flutter/material.dart';

final RegExp persian = RegExp(r'^[\u0600-\u06FF]+');
final RegExp english = RegExp(r'^[a-zA-Z]+');
final RegExp arabic = RegExp(r'^[\u0621-\u064A]+');
final RegExp chinese = RegExp(r'^[\u4E00-\u9FFF]+');
final RegExp japanese = RegExp(r'^[\u3040-\u30FF]+');
final RegExp korean = RegExp(r'^[\uAC00-\uD7AF]+');
final RegExp ukrainian = RegExp(r'^[\u0400-\u04FF\u0500-\u052F]+');
final RegExp russian = RegExp(r'^[\u0400-\u04FF]+');
final RegExp italian = RegExp(r'^[\u00C0-\u017F]+');
final RegExp french = RegExp(r'^[\u00C0-\u017F]+');
final RegExp spanish = RegExp(
    r'[\u00C0-\u024F\u1E00-\u1EFF\u2C60-\u2C7F\uA720-\uA7FF\u1D00-\u1D7F]+');

/// list all Male voices from this region
List<Map<String, String>> maleLanguage({required String region}) {
  switch (region) {
    case '':
      return [];
    default:
      return [];
  }
}
