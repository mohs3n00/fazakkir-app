class PrayerTimeUtils {
  /// Rounds the time to the nearest minute, ceiling upwards if seconds > 0.
  /// This ensures that if the time is 12:00:01, it becomes 12:01:00.
  /// If the time is 12:00:00, it remains 12:00:00.
  /// This aligns with DateFormat.jm() which truncates seconds, avoiding
  /// the perception of the alarm being "late" (ringing at 12:00:59 while UI shows 12:00).
  static DateTime ceilToMinute(DateTime time) {
    if (time.second > 0 || time.millisecond > 0 || time.microsecond > 0) {
      return time
          .add(const Duration(minutes: 1))
          .copyWith(second: 0, millisecond: 0, microsecond: 0);
    }
    return time.copyWith(second: 0, millisecond: 0, microsecond: 0);
  }
}
