import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:machi_app/datas/interactive.dart';

/// load themes from local to reduce api calls
Future<List<InteractiveTheme>> loadThemes() async {
  String jsonContent = await rootBundle.loadString('assets/json/theme.json');
  List<dynamic> decodedJson = jsonDecode(jsonContent);
  List<InteractiveTheme> themes = [];
  for (var item in decodedJson) {
    InteractiveTheme _theme = InteractiveTheme.fromJson(item);
    themes.add(_theme);
  }
  return themes;
}
