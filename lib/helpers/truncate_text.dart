String truncateText(
    {required int maxLength, required String text, bool? removeNewline}) {
  String newText = removeNewline == true ? text.replaceAll("\n", " ") : text;
  int strLength = newText.length;
  if (strLength > maxLength) {
    return "${newText.substring(0, maxLength)}...";
  }
  return newText;
}
