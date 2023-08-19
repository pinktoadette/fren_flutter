import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> clearCached() async {
  final cacheManager = DefaultCacheManager();
  await cacheManager.emptyCache();
}

Future<void> scheduleCacheClearing() async {
  final prefs = await SharedPreferences.getInstance();
  final lastCacheClearTimestamp =
      prefs.getInt('last_cache_clear_timestamp') ?? 0;
  final currentTime = DateTime.now().millisecondsSinceEpoch;

  if (currentTime - lastCacheClearTimestamp >=
      const Duration(days: 7).inMilliseconds) {
    // Clear the cache
    await clearCached();

    // Update the last cache clear timestamp
    await prefs.setInt('last_cache_clear_timestamp', currentTime);
  }
}

Future<void> initializeCacheTimestampAndSchedule() async {
  final prefs = await SharedPreferences.getInstance();
  final lastCacheClearTimestamp =
      prefs.getInt('last_cache_clear_timestamp') ?? 0;
  final currentTime = DateTime.now().millisecondsSinceEpoch;

  if (currentTime - lastCacheClearTimestamp >=
      const Duration(days: 7).inMilliseconds) {
    await clearCached();

    // Update the last cache clear timestamp
    await prefs.setInt('last_cache_clear_timestamp', currentTime);
  }

  // Schedule cache clearing for future runs
  await scheduleCacheClearing();
}
