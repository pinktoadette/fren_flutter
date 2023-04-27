import 'dart:math';

import 'package:fren_app/constants/constants.dart';

bool isYesterday(d1, d2) {
  return (d1.day - 1) == d2.day && d1.month == d2.month && d1.year == d2.year;
}

String formatDate(int epochDate) {
  final d1 = DateTime.now();
  final d2 = d1.subtract(const Duration(days: 1));
  final comparedDate = DateTime.fromMicrosecondsSinceEpoch(epochDate * 1000);
  int daysDiff = d2.difference(comparedDate).inDays;

  bool isYes = isYesterday(d1, d2);

  if (daysDiff <= 1 && isYes) {
    return "Yesterday";
  }
  if (daysDiff > 1) {
    String month = "${comparedDate.month}";
    String day = "${comparedDate.day}";
    if (comparedDate.month < 10) {
      month = "0${comparedDate.month}";
    }
    if (comparedDate.day < 10) {
      day = "0${comparedDate.day}";
    }
    return "${comparedDate.year}-$month-$day";
  } else {
    final min = comparedDate.minute < 10
        ? "0${comparedDate.minute}"
        : comparedDate.minute;
    return "${comparedDate.hour}:$min";
  }
}

/// get current datetime in epoch
int getDateTimeEpoch() {
  DateTime dateTime = DateTime.now();
  return dateTime.millisecondsSinceEpoch;
}

int countdown(int timestamp) {
  final d1 = DateTime.now();
  final time = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
  final stopAt = time.add(const Duration(minutes: 5));
  final diff = stopAt.difference(d1).inSeconds;

  return max(0, diff);
}
