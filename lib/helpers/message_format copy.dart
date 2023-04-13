/// get current datetime in epoch
int getDateTimeEpoch() {
  DateTime dateTime = DateTime.now();
  return dateTime.millisecondsSinceEpoch;
}
