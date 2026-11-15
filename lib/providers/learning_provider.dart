import 'package:flutter/material.dart';

import '../core/constants/learning_content.dart';
import '../core/database/database_helper.dart';
import '../core/utils/formatters.dart';
import '../models/models.dart';

class LearningProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  final Set<String> _doneLessons = {};
  List<StudySession> _sessions = [];

  List<StudySession> get sessions => List.unmodifiable(_sessions);

  Future<void> load() async {
    final db = await _db.database;
    final progressRows = await db.query('lesson_progress');
    _doneLessons
      ..clear()
      ..addAll(progressRows
          .where((r) => (r['is_done'] as int? ?? 0) == 1)
          .map((r) => '${r['course_key']}:${r['lesson_index']}'));
    _sessions = (await db.query('study_sessions', orderBy: 'date DESC, id DESC'))
        .map(StudySession.fromMap)
        .toList();
    notifyListeners();
  }

  bool isLessonDone(String courseKey, int index) => _doneLessons.contains('$courseKey:$index');

  Future<void> toggleLesson(String courseKey, int index, bool done) async {
    final db = await _db.database;
    if (done) {
      await db.insert(
        'lesson_progress',
        {'course_key': courseKey, 'lesson_index': index, 'is_done': 1},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _doneLessons.add('$courseKey:$index');
    } else {
      await db.delete(
        'lesson_progress',
        where: 'course_key = ? AND lesson_index = ?',
        whereArgs: [courseKey, index],
      );
      _doneLessons.remove('$courseKey:$index');
    }
    notifyListeners();
  }

  Future<void> addStudyTime(String courseKey, int minutes, DateTime date) async {
    if (minutes <= 0) return;
    final db = await _db.database;
    final session = StudySession(
      courseKey: courseKey,
      minutes: minutes,
      date: date,
      createdAt: DateTime.now(),
    );
    final id = await db.insert('study_sessions', session.toMap()..remove('id'));
    _sessions = [session.copyWith(id: id), ..._sessions];
    notifyListeners();
  }

  int minutesForCourse(String courseKey) =>
      _sessions.where((s) => s.courseKey == courseKey).fold(0, (sum, s) => sum + s.minutes);

  int minutesOnDay(DateTime day) =>
      _sessions.where((s) => sameDay(s.date, day)).fold(0, (sum, s) => sum + s.minutes);

  int get todayMinutes => minutesOnDay(DateTime.now());

  int get totalMinutes => _sessions.fold(0, (sum, s) => sum + s.minutes);

  int lessonsDoneForCourse(String courseKey) {
    var count = 0;
    for (var i = 0; i < CourseCatalog.byKey(courseKey).lessons.length; i++) {
      if (_doneLessons.contains('$courseKey:$i')) count++;
    }
    return count;
  }

  int get totalLessonsDone =>
      CourseCatalog.courses.fold(0, (n, c) => n + lessonsDoneForCourse(c.key));

  double courseProgress(String courseKey) {
    final total = CourseCatalog.byKey(courseKey).lessons.length;
    if (total == 0) return 0;
    return lessonsDoneForCourse(courseKey) / total;
  }

  double get overallProgress {
    final total = CourseCatalog.totalLessons;
    if (total == 0) return 0;
    return totalLessonsDone / total;
  }
}
