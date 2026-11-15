import 'package:flutter_test/flutter_test.dart';
import 'package:grs_life/core/l10n/app_localizations.dart';
import 'package:grs_life/core/utils/formatters.dart';
import 'package:grs_life/models/models.dart';

void main() {
  group('models', () {
    test('Task map roundtrip', () {
      final task = Task(
        id: 3,
        title: 'Buy milk',
        note: '2 liters',
        category: 'personal',
        priority: 2,
        dueDate: DateTime(2025, 3, 10, 14, 30),
        reminderMinutes: 15,
        isDone: true,
        createdAt: DateTime(2025, 3, 9, 8, 0),
      );
      final restored = Task.fromMap(task.toMap());
      expect(restored.id, 3);
      expect(restored.title, 'Buy milk');
      expect(restored.note, '2 liters');
      expect(restored.category, 'personal');
      expect(restored.priority, 2);
      expect(restored.dueDate, DateTime(2025, 3, 10, 14, 30));
      expect(restored.reminderMinutes, 15);
      expect(restored.isDone, isTrue);
    });

    test('MoneyEntry roundtrip and helpers', () {
      final entry = MoneyEntry(
        id: 1,
        type: MoneyEntry.typeIncome,
        amount: 1500000,
        category: 'salary',
        note: '',
        date: DateTime(2025, 3, 1),
        createdAt: DateTime(2025, 3, 1),
      );
      final restored = MoneyEntry.fromMap(entry.toMap());
      expect(restored.amount, 1500000);
      expect(restored.isIncome, isTrue);
    });

    test('FinancialGoal progress is clamped and accurate', () {
      final goal = FinancialGoal(
        name: 'Car',
        targetAmount: 10000000,
        savedAmount: 2500000,
        createdAt: DateTime(2025, 1, 1),
      );
      expect(goal.progress, closeTo(0.25, 0.0001));
      expect(goal.isComplete, isFalse);
      expect(goal.copyWith(savedAmount: 10000000).isComplete, isTrue);
      expect(goal.copyWith(savedAmount: 20000000).progress, 1.0);
    });
  });

  group('formatters', () {
    test('groupDigits inserts space groups', () {
      expect(groupDigits(0), '0');
      expect(groupDigits(500), '500');
      expect(groupDigits(1000), '1 000');
      expect(groupDigits(1234567), '1 234 567');
      expect(groupDigits(-9876543), '-9 876 543');
    });

    test('formatMoney uses UZS suffix', () {
      expect(formatMoney(1500000, uz: true), "1 500 000 so'm");
      expect(formatMoney(1500000, uz: false), '1 500 000 сум');
    });

    test('formatMoneyShort abbreviates large amounts', () {
      expect(formatMoneyShort(2500000, uz: true), "2.5 mln so'm");
      expect(formatMoneyShort(2500000, uz: false), '2.5 млн сум');
      expect(formatMoneyShort(50000, uz: true), "50.0 ming so'm");
      expect(formatMoneyShort(999, uz: false), '999 сум');
    });

    test('monthKeyOf formats zero-padded keys', () {
      expect(monthKeyOf(DateTime(2025, 3, 14)), '2025-03');
      expect(monthKeyOf(DateTime(2025, 12, 31)), '2025-12');
    });

    test('sameDay ignores time', () {
      expect(sameDay(DateTime(2025, 3, 14, 8), DateTime(2025, 3, 14, 23)), isTrue);
      expect(sameDay(DateTime(2025, 3, 14), DateTime(2025, 3, 15)), isFalse);
    });

    test('date formatting in both languages', () {
      final d = DateTime(2025, 3, 14);
      expect(formatDate(d, uz: true), '14 mart 2025');
      expect(formatDate(d, uz: false), '14 марта 2025');
      expect(weekdayName(d, uz: true), 'Juma');
      expect(weekdayName(d, uz: false), 'Пятница');
    });
  });

  group('localizations', () {
    test('uz is default language', () {
      final uz = AppLocalizations(const Locale('uz'));
      expect(uz.isUz, isTrue);
      expect(uz.t('save'), 'Saqlash');
      expect(uz.t('nav_finance'), 'Moliya');
      expect(uz.t('unknown_key_xyz'), 'unknown_key_xyz');
    });

    test('ru translations work', () {
      final ru = AppLocalizations(const Locale('ru'));
      expect(ru.isUz, isFalse);
      expect(ru.t('save'), 'Сохранить');
      expect(ru.t('nav_finance'), 'Финансы');
    });

    test('tf replaces parameters', () {
      final uz = AppLocalizations(const Locale('uz'));
      expect(
        uz.tf('greeting_morning', {'%s': 'Ali'}),
        'Xayrli tong, Ali',
      );
    });
  });
}
