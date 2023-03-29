String formatDate(int epochDate) {
  final d1 = DateTime.now();
  final d2 = d1.add(const Duration(days: 1));
  final comparedDate = DateTime.fromMicrosecondsSinceEpoch(epochDate * 1000);

  if (d2.difference(comparedDate).inDays > 1) {
    return "${comparedDate.year}-${comparedDate.month}-${comparedDate.day}";
  } else {
    return "${comparedDate.hour}:${comparedDate.minute}";
  }
}
