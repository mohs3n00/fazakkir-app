import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import 'location_service.dart';

final prayerConfigServiceProvider = Provider<PrayerConfigService>((ref) {
  return PrayerConfigService(ref);
});

class PrayerConfigService {
  final Ref _ref;

  static const String _kCachedLat = 'prayer_config_cached_lat';
  static const String _kCachedLng = 'prayer_config_cached_lng';
  static const String _kCachedTimestamp = 'prayer_config_cached_timestamp';

  PrayerConfigService(this._ref);

  /// Returns coordinates, either cached (if valid < 12 hours) or fresh.
  /// If [forceRefresh] is true, it will bypass cache.
  Future<Coordinates> getCoordinates({bool forceRefresh = false}) async {
    final prefs = _ref.read(sharedPreferencesProvider);

    if (!forceRefresh) {
      final cachedLat = prefs.getDouble(_kCachedLat);
      final cachedLng = prefs.getDouble(_kCachedLng);
      final cachedTimestamp = prefs.getInt(_kCachedTimestamp);

      if (cachedLat != null && cachedLng != null && cachedTimestamp != null) {
        final lastUpdate = DateTime.fromMillisecondsSinceEpoch(cachedTimestamp);
        final now = DateTime.now();

        // Check if cache is within 12 hours
        if (now.difference(lastUpdate).inHours < 12) {
          return Coordinates(cachedLat, cachedLng);
        }
      }
    }

    // Fetch fresh location
    try {
      final locationService = _ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();

      if (position != null) {
        // Cache new location
        await prefs.setDouble(_kCachedLat, position.latitude);
        await prefs.setDouble(_kCachedLng, position.longitude);
        await prefs.setInt(
          _kCachedTimestamp,
          DateTime.now().millisecondsSinceEpoch,
        );

        return Coordinates(position.latitude, position.longitude);
      }
    } catch (e) {
      // Fallback if location service fails, try to return cached if available even if old
      final cachedLat = prefs.getDouble(_kCachedLat);
      final cachedLng = prefs.getDouble(_kCachedLng);
      if (cachedLat != null && cachedLng != null) {
        return Coordinates(cachedLat, cachedLng);
      }
    }

    // Default Cairo fallback if everything fails
    return Coordinates(30.0444, 31.2357);
  }
}
