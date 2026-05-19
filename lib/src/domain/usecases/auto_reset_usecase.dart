import 'package:clock/clock.dart';

import '../../core/constants/azkar_day_phases.dart';
import '../entities/zekr_category.dart';
import '../repositories/azkar_repository.dart';

class AutoResetUseCase {
  const AutoResetUseCase(this._repository);
  final AzkarRepository _repository;

  Future<List<ZekrCategory>> call(List<ZekrCategory> categories) async {
    // injectable via package [clock] in tests so we can mock/override it
    // its better than using DateTime.now() because its not testable :)
    final now    = clock.now(); 
    final result = <ZekrCategory>[];

    for (final category in categories) {
      result.add(await _process(category, now));
    }
    return result;
  }

  Future<ZekrCategory> _process(ZekrCategory category, DateTime now) async {
    // general categories never auto reset
    if (category.type == CategoryType.general) return category;
    final lastReset = category.lastResetTime;
    if (lastReset == null) {
      await _repository.saveLastResetTime(category.id, now);
      return category.copyWith(lastResetTime: now);
    }

    final shouldReset = switch (category.type) {
      CategoryType.sabah   => AzkarDayPhases.needsSabahReset(lastReset, now),
      CategoryType.masaa   => AzkarDayPhases.needsMasaaReset(lastReset, now),
      CategoryType.general => false,
    };

    if (!shouldReset) return category;

    await _repository.resetCategory(category.id);
    await _repository.saveLastResetTime(category.id, now);

    return category.copyWith(
      azkar: category.azkar.map((z) => z.copyWith(currentCount: 0)).toList(),
      lastResetTime: now,
    );
  }
}
