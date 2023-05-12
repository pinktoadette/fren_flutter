import 'package:audio_service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:machi_app/api/machi/stream_api.dart';

class MediaStreamItem {
  final String id;
  final String? title;
  final String? album;
  final User? artist;
  final BytesSource? bytes;
  final String? url;
  final String text;
  final String language;
  final String voiceName;
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
    required this.text,
    required this.language,
    required this.voiceName,
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
      String? text,
      String? language,
      String? voiceName,
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
        text: text ?? this.text,
        language: language ?? this.language,
        voiceName: voiceName ?? this.voiceName,
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
      'text': text,
      'voiceName': voiceName,
      'genre': genre,
      'duration': duration?.inMicroseconds ?? 0,
      'rating': rating
    };
  }
}
