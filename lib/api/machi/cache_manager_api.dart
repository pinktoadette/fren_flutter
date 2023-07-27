import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'dart:convert';

class CachedApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<Map<String, dynamic>?> cachedUrl(String url) async {
    final cacheManager = DefaultCacheManager();

    FileInfo? cachedFile = await cacheManager.getFileFromCache(url);
    if (cachedFile != null && cachedFile.validTill.isAfter(DateTime.now())) {
      final jsonString = await cachedFile.file.readAsString();
      final cachedData = json.decode(jsonString);
      return cachedData;
    }

    return null;
  }

  Future<void> cacheUrl(String url, Map<String, dynamic> data) async {
    final cacheManager = DefaultCacheManager();
    Uint8List bytes = Uint8List.fromList(utf8.encode(json.encode(data)));

    await cacheManager.putFile(
      url,
      bytes,
    );
  }
}
