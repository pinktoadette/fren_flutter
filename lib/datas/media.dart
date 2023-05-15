import 'package:audio_service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:machi_app/api/machi/stream_api.dart';
import 'package:machi_app/audio/notifiers/play_button_notifier.dart';

class MediaStreamTracker {
  final ButtonState state; // the state of the media being read
  final MediaStreamItem item; // the media that's being read
  final String voiceSelection; // selected voice
  final List<String> voiceList; // list of available voice to read
  MediaStreamTracker(
      {required this.state,
      required this.item,
      required this.voiceSelection,
      required this.voiceList});
  MediaStreamTracker copyWith(
      {ButtonState? state,
      MediaStreamItem? item,
      String? voiceSelection,
      List<String>? voiceList}) {
    return MediaStreamTracker(
        state: state ?? this.state,
        item: this.item,
        voiceList: voiceList ?? this.voiceList,
        voiceSelection: voiceSelection ?? this.voiceSelection);
  }
}

class TTSLanguage {
  String language;
  String region;
  TTSLanguage({required this.region, required this.language});
}

/// BytesSource stream purposes
class MediaStreamCharacter {
  String id;
  String username;
  final String text;
  final TTSLanguage language;
  final String voiceName;
  MediaStreamCharacter(
      {required this.id,
      required this.username,
      required this.text,
      required this.language,
      required this.voiceName});
}

class MediaStreamItem {
  final String id;
  final String? title;
  final String? album;
  final User? artist;
  final BytesSource? bytes;
  final String? url;
  final MediaStreamCharacter? character;
  final String? genre;
  final Duration? duration;
  final String? displayTitle;
  final String? displaySubtitle;
  final Rating? rating; // using audio service

  MediaStreamItem({
    required this.id,
    this.title,
    this.album,
    this.artist,
    this.bytes,
    this.url,
    this.character,
    this.genre,
    this.duration,
    this.displayTitle,
    this.displaySubtitle,
    this.rating,
  });

  MediaStreamItem copyWith(
      {String? title,
      String? album,
      User? artist,
      BytesSource? bytes,
      String? url,
      MediaStreamCharacter? character,
      String? genre,
      Duration? duration,
      String? displayTitle,
      String? displaySubtitle,
      Rating? rating}) {
    return MediaStreamItem(
        id: id,
        title: title ?? this.title,
        artist: artist ?? this.artist,
        bytes: bytes ?? this.bytes,
        url: url ?? this.url,
        displayTitle: displayTitle ?? this.displayTitle,
        displaySubtitle: displaySubtitle ?? this.displaySubtitle,
        character: character ?? this.character,
        genre: genre ?? this.genre,
        duration: duration ?? this.duration,
        rating: rating ?? this.rating);
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'artist': artist,
      'bytes': bytes,
      'url': url,
      'displayTitle': displayTitle,
      'displaySubtitle': displaySubtitle,
      'character': character,
      'genre': genre,
      'duration': duration?.inMicroseconds ?? 0,
      'rating': rating
    };
  }
}
