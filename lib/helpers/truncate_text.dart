String truncateText(int maxLength, String text) {
  int strLength = text.length;
  if (strLength > maxLength) {
    return "${text.substring(0, maxLength)}...";
  }
  return text;
}
