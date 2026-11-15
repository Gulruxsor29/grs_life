import 'package:flutter/material.dart';

import '../core/database/database_helper.dart';
import '../models/models.dart';

class JournalProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<JournalEntry> _entries = [];

  List<JournalEntry> get entries => List.unmodifiable(_entries);

  Future<void> load() async {
    final db = await _db.database;
    _entries =
        (await db.query('journal', orderBy: 'created_at DESC')).map(JournalEntry.fromMap).toList();
    notifyListeners();
  }

  Future<void> add(JournalEntry entry) async {
    final db = await _db.database;
    final id = await db.insert('journal', entry.toMap()..remove('id'));
    _entries = [entry.copyWith(id: id), ..._entries];
    notifyListeners();
  }

  Future<void> update(JournalEntry entry) async {
    final db = await _db.database;
    await db.update(
      'journal',
      entry.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
    _entries = _entries.map((e) => e.id == entry.id ? entry : e).toList();
    notifyListeners();
  }

  Future<void> delete(JournalEntry entry) async {
    final db = await _db.database;
    await db.delete('journal', where: 'id = ?', whereArgs: [entry.id]);
    _entries = _entries.where((e) => e.id != entry.id).toList();
    notifyListeners();
  }
}
