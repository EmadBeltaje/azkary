import 'package:azkary/src/core/constants/azkar_day_phases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Azkary phase -> isSabahPhase / isMasaaPhase', () {
    test('11:59 is sabah', () {
      expect(AzkarDayPhases.isSabahPhase(DateTime(2026, 1, 1, 11, 59)), true);
    });
    test('12:00 is masaa', () {
      expect(AzkarDayPhases.isMasaaPhase(DateTime(2026, 1, 1, 12, 0)), true);
      expect(AzkarDayPhases.isSabahPhase(DateTime(2026, 1, 1, 12, 0)), false);
    });
    test('00:00 is sabah', () {
      expect(AzkarDayPhases.isSabahPhase(DateTime(2026, 1, 1, 0, 0)), true);
    });
    test('23:59 is masaa', () {
      expect(AzkarDayPhases.isMasaaPhase(DateTime(2026, 1, 1, 23, 59)), true);
    });
  });

  group('AzkarDayPhases.needsSabahReset', () {
    test('yesterday morning -> resets this morning', () {
      final lastReset = DateTime(2026, 1, 1, 7, 0);
      final now = DateTime(2026, 1, 2, 6, 0);
      expect(AzkarDayPhases.needsSabahReset(lastReset, now), isTrue);
    });

    test('same morning -> no reset', () {
      final lastReset = DateTime(2026, 1, 1, 5, 0);
      final now = DateTime(2026, 1, 1, 7, 0);
      expect(AzkarDayPhases.needsSabahReset(lastReset, now), isFalse);
    });

    test('now is masaa -> no sabah reset (not needed at this day reset tomarrow)', () {
      final lastReset = DateTime(2026, 1, 1, 7, 0);
      final now = DateTime(2026, 1, 1, 15, 0);
      expect(AzkarDayPhases.needsSabahReset(lastReset, now), isFalse);
    });

    test('cross-day same calendar morning phase edge', () {
      final lastReset = DateTime(2026, 6, 10, 11, 0);
      final now = DateTime(2026, 6, 11, 6, 0);
      expect(AzkarDayPhases.needsSabahReset(lastReset, now), isTrue);
    });
  });

  group('AzkarDayPhases.needsMasaaReset', () {
    test('morning last reset -> evening now triggers masaa reset', () {
      final lastReset = DateTime(2026, 1, 1, 8, 0);
      final now = DateTime(2026, 1, 1, 15, 0);
      expect(AzkarDayPhases.needsMasaaReset(lastReset, now), isTrue);
    });

    test('already reset this evening -> no reset', () {
      final lastReset = DateTime(2026, 1, 1, 13, 0);
      final now = DateTime(2026, 1, 1, 15, 0);
      expect(AzkarDayPhases.needsMasaaReset(lastReset, now), isFalse);
    });

    test('now is sabah -> no masaa reset', () {
      final lastReset = DateTime(2026, 1, 1, 13, 0);
      final now = DateTime(2026, 1, 1, 8, 0);
      expect(AzkarDayPhases.needsMasaaReset(lastReset, now), isFalse);
    });

    test('different day evening -> reset due', () {
      final lastReset = DateTime(2026, 2, 1, 20, 0);
      final now = DateTime(2026, 2, 2, 14, 0);
      expect(AzkarDayPhases.needsMasaaReset(lastReset, now), isTrue);
    });
  });
}
