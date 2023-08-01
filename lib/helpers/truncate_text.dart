import 'package:machi_app/datas/script.dart';

String truncateText(
    {required int maxLength, required String text, bool? removeNewline}) {
  String newText = removeNewline == true ? text.replaceAll("\n", " ") : text;
  int strLength = newText.length;
  if (strLength > maxLength) {
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
      maxLength: remainingLength,
      text: script.text ?? '',
    );

    aggregatedText += truncatedText;
    totalLength += truncatedText.length;

    if (totalLength >= 250) {
      break;
    }
  }

  return aggregatedText;
}
