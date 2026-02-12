import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationServiceProvider = Provider((ref) => LocationService());

class LocationService {
  /// Get current position safely - returns null on any error
  /// Never throws exceptions to prevent app crashes
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null; // Safe return instead of error
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return null; // Safe return instead of error
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null; // Safe return instead of error
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return position;
    } catch (e) {
      return null; // Safe fallback on any exception
    }
  }
}
