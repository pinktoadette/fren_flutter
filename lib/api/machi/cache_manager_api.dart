import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Caches url where needed.
class CachingHelper {
  final CacheManager _cacheManager = DefaultCacheManager();

  Future<Map<String, dynamic>?> cachedUrl(
    String url,
    Duration maxCacheAge,
  ) async {
    FileInfo? cachedFile = await _cacheManager.getFileFromCache(url);

    if (cachedFile != null && cachedFile.validTill.isAfter(DateTime.now())) {
      final jsonString = await cachedFile.file.readAsString();
      final cachedData = json.decode(jsonString);
      return cachedData;
    }

    return null;
  }

  /// take json, no class structure.
  Future<void> cacheUrl(
    String url,
    Map<String, dynamic> data,
    Duration maxCacheAge,
  ) async {
    Uint8List bytes = Uint8List.fromList(utf8.encode(json.encode(data)));

    await _cacheManager.putFile(
      url,
      bytes,
      maxAge: maxCacheAge,
    );
  }
}
