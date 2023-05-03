import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:fren_app/helpers/date_format.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class StreamApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<void> getOrCreateToken() async {
    /// suggests to use token every 10mins
    final box = GetStorage();
    box.write('streamToken', getDateTimeEpoch());
    int timestamp = box.read('streamToken');
  }

  Future<String> getAuthToken() async {
    String url = '${baseUri}audio/auth';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url);
    return response.data;
  }

  Future<dynamic> streamAudio(String key, String text, String region) async {
    String url =
        'https://$region.tts.speech.microsoft.com/cognitiveservices/v1';
    debugPrint("Requesting URL $url");
    final request = http.Request(
      'POST',
      Uri.parse(url),
    );
    request.headers.addAll({
      HttpHeaders.authorizationHeader: 'Bearer $key',
      'content-type': 'application/ssml+xml',
      'X-Microsoft-OutputFormat': 'audio-16khz-128kbitrate-mono-mp3',
      'user-agent': 'machitts'
    });

    var xml =
        "<speak version='1.0' xml:lang='en-US'><voice xml:lang='en-US' xml:gender='Female' name='en-US-SaraNeural'> $text </voice></speak>";

    request.body = xml;
    var streamedResponse = await http.Client().send(request);
    return streamedResponse;
  }
}

class BytesSource extends StreamAudioSource {
  final Uint8List _buffer;

  BytesSource(this._buffer) : super(tag: 'AudioSource');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    // Returning the stream audio response with the parameters
    start ??= 0;
    end ??= _buffer.length;

    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_buffer.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
