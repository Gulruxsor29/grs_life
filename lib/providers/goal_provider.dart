import 'package:flutter/material.dart';

import '../core/database/database_helper.dart';
import '../models/models.dart';

class GoalProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<PersonalGoal> _goals = [];

  List<PersonalGoal> get goals => List.unmodifiable(_goals);

  List<PersonalGoal> get activeGoals => _goals.where((g) => !g.isDone).toList();

  int get doneCount => _goals.where((g) => g.isDone).length;

  Future<void> load() async {
    final db = await _db.database;
    _goals = (await db.query('goals', orderBy: 'is_done ASC, created_at DESC'))
        .map(PersonalGoal.fromMap)
        .toList();
    notifyListeners();
  }

  Future<void> add(PersonalGoal goal) async {
    final db = await _db.database;
    final id = await db.insert('goals', goal.toMap()..remove('id'));
    _goals = [goal.copyWith(id: id), ..._goals];
    notifyListeners();
  }

  Future<void> update(PersonalGoal goal) async {
    final db = await _db.database;
    await db.update(
      'goals',
      goal.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
    _goals = _goals.map((g) => g.id == goal.id ? goal : g).toList();
    notifyListeners();
  }

  Future<void> setProgress(PersonalGoal goal, int progress) async {
    final clamped = progress.clamp(0, 100);
    final updated = goal.copyWith(progress: clamped, isDone: clamped >= 100);
    await update(updated);
  }

  Future<void> toggleDone(PersonalGoal goal) async {
    final updated = goal.copyWith(isDone: !goal.isDone);
    await update(updated);
  }

  Future<void> delete(PersonalGoal goal) async {
    final db = await _db.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [goal.id]);
    _goals = _goals.where((g) => g.id != goal.id).toList();
    notifyListeners();
  }
}
