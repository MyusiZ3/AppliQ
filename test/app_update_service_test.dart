import 'package:flutter_test/flutter_test.dart';
import 'package:appliq/services/app_update_service.dart';
import 'package:appliq/utils/language_manager.dart';

void main() {
  group('AppUpdateService SemVer Tests', () {
    test('parseSemVer handles various formats', () {
      expect(AppUpdateService.parseSemVer('v1.0.7'), [1, 0, 7]);
      expect(AppUpdateService.parseSemVer('1.0.7+3'), [1, 0, 7]);
      expect(AppUpdateService.parseSemVer('V2.1.0'), [2, 1, 0]);
      expect(AppUpdateService.parseSemVer('1.2'), [1, 2, 0]);
      expect(AppUpdateService.parseSemVer('invalid'), [0, 0, 0]);
    });

    test('compareSemVer correctly orders versions', () {
      expect(AppUpdateService.compareSemVer('1.0.8', '1.0.7'), greaterThan(0));
      expect(AppUpdateService.compareSemVer('1.1.0', '1.0.9'), greaterThan(0));
      expect(AppUpdateService.compareSemVer('2.0.0', '1.9.9'), greaterThan(0));
      expect(AppUpdateService.compareSemVer('1.0.7', '1.0.7'), equals(0));
      expect(AppUpdateService.compareSemVer('1.0.6', '1.0.7'), lessThan(0));
    });

    test('calculateSemVerGap correctly determines version distance and force update threshold', () {
      final current = [1, 0, 7];

      // 1 patch ahead: gap = 1 -> Optional update
      final gap1 = AppUpdateService.calculateSemVerGap(current, [1, 0, 8]);
      expect(gap1, 1);
      expect(gap1 >= 3, isFalse);

      // 2 patches ahead: gap = 2 -> Optional update
      final gap2 = AppUpdateService.calculateSemVerGap(current, [1, 0, 9]);
      expect(gap2, 2);
      expect(gap2 >= 3, isFalse);

      // 3 patches ahead: gap = 3 -> FORCE UPDATE (Batas toleransi maksimal 3 versi)
      final gap3 = AppUpdateService.calculateSemVerGap(current, [1, 0, 10]);
      expect(gap3, 3);
      expect(gap3 >= 3, isTrue);

      // Minor bump ahead: gap >= 3 -> FORCE UPDATE
      final gapMinor = AppUpdateService.calculateSemVerGap(current, [1, 1, 0]);
      expect(gapMinor >= 3, isTrue);

      // Major bump ahead: gap >= 3 -> FORCE UPDATE
      final gapMajor = AppUpdateService.calculateSemVerGap(current, [2, 0, 0]);
      expect(gapMajor >= 3, isTrue);
    });

    test('LanguageManager changes affect AppLanguage values seamlessly', () {
      LanguageManager.notifier.value = AppLanguage.id;
      expect(LanguageManager.current, AppLanguage.id);

      LanguageManager.notifier.value = AppLanguage.en;
      expect(LanguageManager.current, AppLanguage.en);

      LanguageManager.notifier.value = AppLanguage.ja;
      expect(LanguageManager.current, AppLanguage.ja);

      LanguageManager.notifier.value = AppLanguage.ko;
      expect(LanguageManager.current, AppLanguage.ko);

      // Reset back to id
      LanguageManager.notifier.value = AppLanguage.id;
    });
  });
}

