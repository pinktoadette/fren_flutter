import 'dart:async';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// STEP1:  Stream setup
class StreamSocket {
  final _socketResponse = StreamController<types.Message>();

  void Function(types.Message) get addResponse => _socketResponse.sink.add;

  Stream<types.Message> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}
