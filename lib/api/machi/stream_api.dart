import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:machi_app/helpers/date_format.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class StreamApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Map<String, String> detectLanguage({required String string}) {
    Map<String, String> languageCodes = {
      'lang': 'en',
      'person': 'en-US-SaraNeural'
    };

    final RegExp persian = RegExp(r'^[\u0600-\u06FF]+');
    final RegExp english = RegExp(r'^[a-zA-Z]+');
    final RegExp arabic = RegExp(r'^[\u0621-\u064A]+');
    final RegExp chinese = RegExp(r'^[\u4E00-\u9FFF]+');
    final RegExp japanese = RegExp(r'^[\u3040-\u30FF]+');
    final RegExp korean = RegExp(r'^[\uAC00-\uD7AF]+');
    final RegExp ukrainian = RegExp(r'^[\u0400-\u04FF\u0500-\u052F]+');
    final RegExp russian = RegExp(r'^[\u0400-\u04FF]+');
    final RegExp italian = RegExp(r'^[\u00C0-\u017F]+');
    final RegExp french = RegExp(r'^[\u00C0-\u017F]+');
    final RegExp spanish = RegExp(
        r'[\u00C0-\u024F\u1E00-\u1EFF\u2C60-\u2C7F\uA720-\uA7FF\u1D00-\u1D7F]+');

    if (persian.hasMatch(string)) {
      languageCodes = {'lang': 'fa-IR', 'person': 'fa-IR-FaridNeural'};
    }
    if (english.hasMatch(string)) {
      languageCodes = {'lang': 'en-US', 'person': 'en-US-JasonNeural'};
    }
    if (arabic.hasMatch(string)) {
      languageCodes = {'lang': 'ar-AE', 'person': 'ar-AE-HamdanNeural'};
    }
    if (chinese.hasMatch(string)) {
      languageCodes = {'lang': 'zh-TW', 'person': 'zh-TW-HsiaoChenNeural'};
    }
    if (japanese.hasMatch(string)) {
      languageCodes = {'lang': 'ja-JP', 'person': 'ja-JP-MayuNeural'};
    }
    if (korean.hasMatch(string)) {
      languageCodes = {'lang': 'ko-KR', 'person': 'ko-KR-SeoHyeonNeural'};
    }
    if (russian.hasMatch(string)) {
      languageCodes = {'lang': 'ru-RU', 'person': 'ru-RU-DmitryNeural'};
    }
    if (ukrainian.hasMatch(string)) {
      languageCodes = {'lang': 'uk-UA', 'person': 'uk-UA-PolinaNeural'};
    }
    if (italian.hasMatch(string)) {
      languageCodes = {'lang': 'it-IT', 'person': 'it-IT-FabiolaNeural'};
    }
    if (french.hasMatch(string)) {
      languageCodes = {'lang': 'fr-FR', 'person': 'fr-FR-JacquelineNeural'};
    }
    if (spanish.hasMatch(string)) {
      languageCodes = {'lang': 'es-ES', 'person': 'es-ES-EstrellaNeural'};
    }

    return languageCodes;
  }

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

  Future<http.StreamedResponse> streamAudio(
      String key, String text, String region) async {
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
    Map<String, String> lang = detectLanguage(string: text);

    var xml =
        "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='${lang["lang"]}'><voice name='${lang["person"]}'>$text</voice></speak>";

    request.body = xml;
    var streamedResponse = await http.Client().send(request);
    return streamedResponse;
  }

  Future<BytesSource> setPlayer(Map person, String text) async {
    String token = await getAuthToken();
    http.StreamedResponse streamedResponse = await streamPlayer(
        key: token, text: text, region: 'eastus', lang: person);
    Uint8List data = await streamedResponse.stream.toBytes();
    return BytesSource(data);
  }

  Future<http.StreamedResponse> streamPlayer(
      {required String key,
      required String text,
      required String region,
      Map? lang}) async {
    lang ??= detectLanguage(string: text);
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
        "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='${lang["lang"]}'><voice name='${lang["person"]}'>$text</voice></speak>";

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
