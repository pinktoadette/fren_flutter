String formatDate(int epochDate) {
  final d1 = DateTime.now();
  final d2 = d1.subtract(const Duration(days: 1));
  final comparedDate = DateTime.fromMicrosecondsSinceEpoch(epochDate * 1000);
  int daysDiff = d2.difference(comparedDate).inDays;

  if (daysDiff == 1) {
    return "Yesterday";
  }
  if (daysDiff > 1) {
    return "${comparedDate.year}-${comparedDate.month}-${comparedDate.day}";
  } else {
    final min = comparedDate.minute < 10
        ? "0${comparedDate.minute}"
        : comparedDate.minute;
    return "${comparedDate.hour}:$min";
  }
}
