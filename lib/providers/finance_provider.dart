import 'package:flutter/material.dart';

import '../core/database/database_helper.dart';
import '../core/utils/formatters.dart';
import '../models/models.dart';

class FinanceProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<MoneyEntry> _entries = [];
  final Map<String, int> _budgets = {};
  List<FinancialGoal> _goals = [];

  List<MoneyEntry> get entries => List.unmodifiable(_entries);
  List<FinancialGoal> get goals => List.unmodifiable(_goals);

  Future<void> load() async {
    final db = await _db.database;
    _entries = (await db.query('money_entries', orderBy: 'date DESC, id DESC'))
        .map(MoneyEntry.fromMap)
        .toList();
    _goals = (await db.query('financial_goals', orderBy: 'created_at DESC'))
        .map(FinancialGoal.fromMap)
        .toList();
    final rows = await db.query('budgets');
    _budgets
      ..clear()
      ..addEntries(rows.map((r) => MapEntry(r['month'] as String, (r['amount'] as num).toInt())));
    notifyListeners();
  }

  int totalByType(String type) =>
      _entries.where((e) => e.type == type).fold(0, (sum, e) => sum + e.amount);

  int get balance => totalByType(MoneyEntry.typeIncome) - totalByType(MoneyEntry.typeExpense);

  int monthTotal(String monthKey, String type) => _entries
      .where((e) => e.type == type && monthKeyOf(e.date) == monthKey)
      .fold(0, (sum, e) => sum + e.amount);

  int get monthIncome => monthTotal(monthKeyOf(DateTime.now()), MoneyEntry.typeIncome);
  int get monthExpense => monthTotal(monthKeyOf(DateTime.now()), MoneyEntry.typeExpense);

  Map<String, int> categoryTotals(String monthKey, String type) {
    final result = <String, int>{};
    for (final e in _entries) {
      if (e.type == type && monthKeyOf(e.date) == monthKey) {
        result[e.category] = (result[e.category] ?? 0) + e.amount;
      }
    }
    return result;
  }

  Map<String, int> lastMonthsTotals(int months, String type) {
    final now = DateTime.now();
    final result = <String, int>{};
    for (var i = months - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      result[monthKeyOf(d)] = monthTotal(monthKeyOf(d), type);
    }
    return result;
  }

  int budgetFor(String monthKey) => _budgets[monthKey] ?? 0;

  int get currentBudget => budgetFor(monthKeyOf(DateTime.now()));

  double get budgetUsage => currentBudget <= 0 ? 0 : monthExpense / currentBudget;

  List<MoneyEntry> entriesForMonth(String monthKey) =>
      _entries.where((e) => monthKeyOf(e.date) == monthKey).toList();

  Future<void> addEntry(MoneyEntry entry) async {
    final db = await _db.database;
    final id = await db.insert('money_entries', entry.toMap()..remove('id'));
    _entries = [entry.copyWith(id: id), ..._entries];
    notifyListeners();
  }

  Future<void> deleteEntry(MoneyEntry entry) async {
    final db = await _db.database;
    await db.delete('money_entries', where: 'id = ?', whereArgs: [entry.id]);
    _entries = _entries.where((e) => e.id != entry.id).toList();
    notifyListeners();
  }

  Future<void> setBudget(String monthKey, int amount) async {
    final db = await _db.database;
    await db.insert(
      'budgets',
      {'month': monthKey, 'amount': amount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _budgets[monthKey] = amount;
    notifyListeners();
  }

  Future<void> addGoal(FinancialGoal goal) async {
    final db = await _db.database;
    final id = await db.insert('financial_goals', goal.toMap()..remove('id'));
    _goals = [goal.copyWith(id: id), ..._goals];
    notifyListeners();
  }

  Future<void> updateGoal(FinancialGoal goal) async {
    final db = await _db.database;
    await db.update(
      'financial_goals',
      goal.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
    _goals = _goals.map((g) => g.id == goal.id ? goal : g).toList();
    notifyListeners();
  }

  Future<void> addToGoalProgress(FinancialGoal goal, int amount) async {
    final newSaved = (goal.savedAmount + amount).clamp(0, goal.targetAmount);
    await updateGoal(goal.copyWith(savedAmount: newSaved));
  }

  Future<void> deleteGoal(FinancialGoal goal) async {
    final db = await _db.database;
    await db.delete('financial_goals', where: 'id = ?', whereArgs: [goal.id]);
    _goals = _goals.where((g) => g.id != goal.id).toList();
    notifyListeners();
  }

  int get totalSaved => _goals.fold(0, (sum, g) => sum + g.savedAmount);
}
