import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'prayer_config_service.dart';

final prayerTimesProvider = FutureProvider<PrayerTimes>((ref) async {
  final configService = ref.read(prayerConfigServiceProvider);

  try {
    final myCoordinates = await configService.getCoordinates();

    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;

    return PrayerTimes.today(myCoordinates, params);
  } catch (e) {
    // Fallback to Cairo on any error
    final myCoordinates = Coordinates(30.0444, 31.2357);
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;
    return PrayerTimes.today(myCoordinates, params);
  }
});

final nextPrayerProvider = Provider.family<Prayer, PrayerTimes>((
  ref,
  prayerTimes,
) {
  return prayerTimes.nextPrayer();
});
