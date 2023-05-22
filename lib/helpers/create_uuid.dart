import 'package:uuid/uuid.dart';

String createUUID() {
  String uuid = const Uuid().v4();
  return uuid.replaceAll(RegExp(r'-'), '');
}
