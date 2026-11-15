import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../core/database/database_helper.dart';
import '../core/utils/formatters.dart';
import '../models/models.dart';

class TaskProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  Future<void> load() async {
    final db = await _db.database;
    _tasks = (await db.query('tasks', orderBy: 'due_date ASC, priority DESC, id DESC'))
        .map(Task.fromMap)
        .toList();
    notifyListeners();
  }

  List<Task> tasksForDay(DateTime day) =>
      _tasks.where((t) => sameDay(t.dueDate, day)).toList();

  List<Task> get todayTasks => tasksForDay(DateTime.now());

  List<Task> get openTasks => _tasks.where((t) => !t.isDone).toList();

  List<Task> upcomingWithReminder() {
    final now = DateTime.now();
    final upcoming = _tasks
        .where((t) =>
            !t.isDone &&
            t.reminderMinutes != null &&
            t.dueDate.isAfter(now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return upcoming.take(5).toList();
  }

  double completionRateForDay(DateTime day) {
    final list = tasksForDay(day);
    if (list.isEmpty) return 0;
    final done = list.where((t) => t.isDone).length;
    return done / list.length;
  }

  Future<void> add(Task task) async {
    final db = await _db.database;
    final map = task.toMap()..remove('id');
    final id = await db.insert('tasks', map);
    _tasks = [..._tasks, task.copyWith(id: id)]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  Future<void> update(Task task) async {
    final db = await _db.database;
    await db.update(
      'tasks',
      task.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [task.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await load();
  }

  Future<void> toggleDone(Task task) async {
    final updated = task.copyWith(isDone: !task.isDone);
    final db = await _db.database;
    await db.update(
      'tasks',
      {'is_done': updated.isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [task.id],
    );
    _tasks = _tasks.map((t) => t.id == task.id ? updated : t).toList();
    notifyListeners();
  }

  Future<void> delete(Task task) async {
    final db = await _db.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [task.id]);
    _tasks = _tasks.where((t) => t.id != task.id).toList();
    notifyListeners();
  }

  int doneCountForDay(DateTime day) => tasksForDay(day).where((t) => t.isDone).length;

  int totalCountForDay(DateTime day) => tasksForDay(day).length;
}
