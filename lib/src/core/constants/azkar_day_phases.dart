abstract final class AzkarDayPhases {
  /// morning phase 00:00:00 - 11:59:59 local.
  static bool isSabahPhase(DateTime localNow) => localNow.hour < 12;

  /// evening phase 12:00:00 - 23:59:59 local.
  static bool isMasaaPhase(DateTime localNow) => localNow.hour >= 12;

  /// returns true when a sabah reset is due.
  ///
  /// a reset is due when:
  ///   1. we are currently in the morning phase, and
  ///   2. the last recorded reset was not in today's morning phase.
  static bool needsSabahReset(DateTime lastReset, DateTime localNow) {
    if (!isSabahPhase(localNow)) return false;
    return !(_isSameDay(lastReset, localNow) && isSabahPhase(lastReset));
  }

  /// returns true when a masaa reset is due.
  ///
  /// a reset is due when:
  ///   1. we are currently in the evening phase, and
  ///   2. the last recorded reset was not in today's evening phase.
  static bool needsMasaaReset(DateTime lastReset, DateTime localNow) {
    if (!isMasaaPhase(localNow)) return false;
    return !(_isSameDay(lastReset, localNow) && isMasaaPhase(lastReset));
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
