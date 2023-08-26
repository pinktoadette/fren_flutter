import 'package:encrypt_shared_pref/pref_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

Future<void> clearCached() async {
  final cacheManager = DefaultCacheManager();
  await cacheManager.emptyCache();
}

Future<void> scheduleCacheClearing() async {
  final SecureStorage secureStorage = SecureStorage();
  final lastCacheClearTimestamp = await secureStorage.readInt(
          key: 'last_cache_clear_timestamp', isEncrypted: true) ??
      0;
  final currentTime = DateTime.now().millisecondsSinceEpoch;

  if (currentTime - lastCacheClearTimestamp >=
      const Duration(days: 7).inMilliseconds) {
    // Clear the cache
    await clearCached();

    // Update the last cache clear timestamp
    await secureStorage.writeInt(
        key: 'last_cache_clear_timestamp', value: currentTime);
  }
}

Future<void> initializeCacheTimestampAndSchedule() async {
  final SecureStorage secureStorage = SecureStorage();
  final lastCacheClearTimestamp =
      await secureStorage.readInt(key: 'last_cache_clear_timestamp') ?? 0;
  final currentTime = DateTime.now().millisecondsSinceEpoch;

  if (currentTime - lastCacheClearTimestamp >=
      const Duration(days: 7).inMilliseconds) {
    await clearCached();

    // Update the last cache clear timestamp
    await secureStorage.writeInt(
        key: 'last_cache_clear_timestamp', value: currentTime);
  }

  // Schedule cache clearing for future runs
  await scheduleCacheClearing();
}
