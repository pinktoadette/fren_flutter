import 'dart:math';

import 'package:machi_app/datas/script.dart';

String truncateText(
    {required int maxLength, required String text, bool? removeNewline}) {
  String newText = removeNewline == true ? text.replaceAll("\n", " ") : text;
  int strLength = newText.length;
  if (strLength > maxLength && (strLength > 0 && maxLength > 0)) {
    return "${newText.substring(0, maxLength)}...";
  }
  return newText;
}

String truncateScriptsTo250Chars(
    {required List<Script>? scripts, required int length}) {
  if (scripts == null || scripts.isEmpty) {
    return '';
  }

  String aggregatedText = '';
  int totalLength = 0;

  for (var script in scripts) {
    int remainingLength = length - totalLength;
    String truncatedText = truncateText(
      maxLength: max(0, remainingLength),
      text: script.text ?? '',
    );

    aggregatedText += truncatedText;
    totalLength += truncatedText.length;

    if (totalLength >= length) {
      break;
    }
  }

  return aggregatedText;
}
